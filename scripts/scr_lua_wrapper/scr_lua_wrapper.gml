enum LuaArgType {
	Id,
	Number,
    String,
    Boolean
}

enum BufferType {
	CommandBuffer,
	CommandDataBuffer
}

enum BuiltinCommandType {
	ScriptEnd = 0
}

function buffers_to_descriptor() {
    var _count = argument_count;
    var _parts = array_create(_count);
    
    for (var i = 0; i < _count; ++i) {
        var _buf = argument[i];
        _parts[i] = string(buffer_get_size(_buf)) + "^" + string(buffer_get_address(_buf));
    }
    
    return string_join_ext("|", _parts);
}

function make_handle_data(_category, _name) {
	var _parts = array_create(2);
	_parts[0] = _category;
	_parts[1] = _name;
	
	return string_join_ext("|", _parts);
}

function arg_type_to_buffer_constant(_type) {
	switch (_type) {
	case LuaArgType.Id:
		return buffer_u64;
	case LuaArgType.Number:
		return buffer_f64;
	case LuaArgType.String:
		return buffer_string;
	case LuaArgType.Boolean:
		return buffer_u8;
	}
}

function arg_type_array_to_buffer_constant(_types) {
	var _buffer_constants = [];
	for (var i = 0; i < array_length(_types); ++i) {
		_buffer_constants[i] = arg_type_to_buffer_constant(_types[i]);
	}
	return _buffer_constants;
}

function data_format_to_size(_format) {
	var _size = 0;
	for (var i = 0; i < array_length(_format); ++i) {
		_size += buffer_sizeof(arg_type_to_buffer_constant(_format[i]));
	}
	return _size;
}

function LuaState(command_buffer_size = 16384, command_data_buffer_size = command_buffer_size * 3) constructor {
	__command_buffer = buffer_create(command_buffer_size, buffer_fixed, 1);
	
	if (command_data_buffer_size < command_buffer_size) {
		throw("Buffer allocation requirements not met!");
	}
	
	__command_data_buffer = buffer_create(command_data_buffer_size, buffer_fixed, 1);
	
	__utility_buffer = buffer_create(2, buffer_fixed, 1);
	
	__context = lua_create(buffers_to_descriptor(__command_buffer, __command_data_buffer, __utility_buffer));
	if (__context < 0) throw(gmlua_get_last_error());
	
	static compile = function(_filename) {
		var _id = lua_compile(__context, _filename);
		if (_id < 0) throw(gmlua_get_last_error());
		return _id;
	}
	
	static run = function(_filename) {
		if (lua_run(__context, _filename) < 0) throw(gmlua_get_last_error());
	}
	
	static run_from_id = function(_id) {
		if (lua_run_from_id(__context, _id) < 0) throw(gmlua_get_last_error());
	}
	
	__empty_function = function () {};
	__command_runners = { __empty_function };
	
	static add_function = function(_name, _signature, _runner) {
		var _command_id = lua_add_function(__context, _name, _signature);
		if (_command_id < 0) throw(gmlua_get_last_error());
		__command_runners[_command_id] = _runner;
	}
	
	__tick_handler = function() {};
	
	static on_tick = function(_tick_handler) {
		__tick_handler = _tick_handler;
	}
	
	static on_script_end = function(_script_end_handler) {
		__command_runners[BuiltinCommandType.ScriptEnd] = _script_end_handler;
	}
	
	__dynamic_data = [];
	
	static tick = function() {
		if (__context == null_lua_context) throw("Cannot tick destroyed Lua context");
		
		for (var i = 0; i < array_length(__dynamic_data); ++i) {
			buffer_seek(__dynamic_data[i].buffer, buffer_seek_start, 0);
		}
		
		__tick_handler();
		
		gmlua_check_suspensions(__context);
		
		buffer_seek(__command_buffer, buffer_seek_start, 0);
		
		var _command_count = buffer_read(__command_buffer, buffer_u64);
		
		for (var i = 0; i < _command_count; ++i) {
			var _command_id = buffer_read(__command_buffer, buffer_u32);
			var _data_offset = buffer_read(__command_buffer, buffer_u32);
			
			// Read payload
			if (_data_offset != 4294967295) {
				buffer_seek(__command_data_buffer, buffer_seek_start, _data_offset);
				
				var data_length = buffer_read(__command_data_buffer, buffer_u32);
			}

			__command_runners[_command_id]();
		}
		
		buffer_seek(__utility_buffer, buffer_seek_start, 0);
		
		if (buffer_read(__utility_buffer, buffer_u8)) {
			buffer_resize(__command_buffer, buffer_get_size(__command_buffer) * 2);
			gmlua_rebind_buffer(__context, buffers_to_descriptor(__command_buffer), BufferType.CommandBuffer);
		}
		
		if (buffer_read(__utility_buffer, buffer_u8)) {
			buffer_resize(__command_data_buffer, buffer_get_size(__command_data_buffer) * 2);
			gmlua_rebind_buffer(__context, buffers_to_descriptor(__command_data_buffer), BufferType.CommandDataBuffer);
		}
		
		buffer_seek(__utility_buffer, buffer_seek_start, 0);
		buffer_fill(__utility_buffer, 0, buffer_u8, 0, buffer_get_size(__utility_buffer));
		
		buffer_poke(__command_buffer, 0, buffer_u64, 0);
		buffer_poke(__command_data_buffer, 0, buffer_u64, 8);
	}
	
	static read_arg = function(_arg_type) {
		return buffer_read(__command_data_buffer, arg_type_to_buffer_constant(_arg_type));
	}
	
	static register_category = function(_category) {
		gmlua_register_category(__context, _category);
	}
	
	static find_handle = function(_category, _name) {
		return gmlua_get_existing_handle(__context, _category, _name);
	}
	
	static __create_handle = function(_category, _name, _format) {
		var _buffer = buffer_create(data_format_to_size(_format), buffer_fixed, 1);
		var _index = gmlua_register_handle(__context, make_handle_data(_category, _name), buffers_to_descriptor(_buffer));
		__dynamic_data[_index] = { buffer: _buffer, format: _format, buffer_constant_format: arg_type_array_to_buffer_constant(_format) };
		return _index;
	}
	
	static register_handle = function(_category, _name, _format) {
		var _possible_existing = gmlua_get_existing_handle(__context, _category, _name);
		if (_possible_existing != invalid_gmlua_handle) throw("Handle under category, \"" + _category + "\", with name, \"" + _name + "\", already exists");
		
		return __create_handle(_category, _name, _format);
	}
	
	static try_register_handle = function(_category, _name, _format) {
		var _handle = find_handle(_category, _name);
		if (_handle != invalid_gmlua_handle) return { created: false };
		
		return { handle: __create_handle(_category, _name, _format), created: true };
	}
	
	static get_or_register_handle = function(_category, _name, _format) {
		var _handle = find_handle(_category, _name);
		if (_handle != invalid_gmlua_handle) return _handle;

		return __create_handle(_category, _name, _format);
	}
	
	static write_dynamic_data = function(_handle) {
		var _data = __dynamic_data[_handle];
		for (var i = 1; i < argument_count; ++i) {
			buffer_write(_data.buffer, _data.buffer_constant_format[i - 1], argument[i]);
		}
	}
	
	static destroy = function() {
		lua_destroy(__context);
		__context = null_lua_context;
		
		for (var i = 0; i < array_length(__dynamic_data); ++i) {
			buffer_delete(__dynamic_data[i].buffer);
		}
		
		buffer_delete(__command_buffer);
		buffer_delete(__command_data_buffer);
		buffer_delete(__utility_buffer);
	}
}