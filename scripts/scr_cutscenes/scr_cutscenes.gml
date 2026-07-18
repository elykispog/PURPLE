function CutsceneSystem() constructor {
	__lua_state = new LuaState();
	__lua_state.register_category("actor");
	
	__gm_to_lua_actor = {};
	
	__cutscene_active = false;
	
	__lua_state.on_script_end(function() {
		__cutscene_active = false;
	});
	
	__lua_state.add_function("game_quit", "n", function() {
		game_end(__lua_state.read_arg(LuaArgType.Number));
	});
	
	__lua_state.add_function("actor_teleport_to", "inn", function() {
		var _obj = instance_find(__gm_to_lua_actor[$ __lua_state.read_arg(LuaArgType.Id)], 0);
		_obj.x = __lua_state.read_arg(LuaArgType.Number);
		_obj.y = __lua_state.read_arg(LuaArgType.Number);
	});
	
	__lua_state.add_function("actor_freeze", "i", function() {
		var _obj = instance_find(__gm_to_lua_actor[$ __lua_state.read_arg(LuaArgType.Id)], 0);
		_obj.freeze();
	});
	
	__lua_state.add_function("actor_unfreeze", "i", function() {
		var _obj = instance_find(__gm_to_lua_actor[$ __lua_state.read_arg(LuaArgType.Id)], 0);
		_obj.unfreeze();
	});
	
	__lua_state.add_function("actor_set_facing", "in", function() {
		var _obj = instance_find(__gm_to_lua_actor[$ __lua_state.read_arg(LuaArgType.Id)], 0);
		_obj.set_facing(__lua_state.read_arg(LuaArgType.Number));
	});
	
	__lua_data_writers = [];
	__lua_state.on_tick(function() {
		for (var i = 0; i < array_length(__lua_data_writers); ++i) {
			__lua_data_writers[i]();
		}
	});
	
	static ensure_actor_cutscene_state = function(_actor, _remove_prefix = true) {
		var _cutscene_name = object_get_name(_actor.object_index);
	
		if (_remove_prefix) {
			if (string_starts_with(_cutscene_name, "obj_")) {
				_cutscene_name = string_delete(_cutscene_name, 1, 4);
			}
		}
	
		var _handle = __lua_state.find_handle("actor", _cutscene_name);
		if (_handle != invalid_gmlua_handle) return;
	
		_handle = __lua_state.register_handle("actor", _cutscene_name, [ LuaArgType.Number, LuaArgType.Number, LuaArgType.Boolean ]);
	
		array_push(__lua_data_writers, method({ lua_state: __lua_state, handle: _handle, actor: _actor }, function() {
			lua_state.write_dynamic_data(handle, actor.x, actor.y, actor.is_frozen());
		}));

		__gm_to_lua_actor[$ _handle] = _actor.object_index;
	}
	
	static load_cutscenes = function(_area) {
		var _base = "cutscenes/" + _area + "/";
		var _files = file_list_recursive(_base, ".lua");
		
		for (var i = 0; i < array_length(_files); ++i) {
			var _file = _files[i];
			
			var _full_path = _base + _file;
			
			__lua_state.compile(_full_path);
		}
	}
	
	static run_cutscene = function(_key, _override_others = false) {
		if (__cutscene_active && !_override_others) return;
		__lua_state.run(string_replace_all(_key, ".", "/") + ".lua");
		__cutscene_active = true;
	}
	
	static is_cutscene_active = function() {
		return __cutscene_active;
	}
	
	static tick = function() {
		__lua_state.tick();
	}
	
	static close = function() {
		__lua_state.destroy();
	}
}

function initalize_cutscene_system() {
	global.cutscene_system = new CutsceneSystem();	
}