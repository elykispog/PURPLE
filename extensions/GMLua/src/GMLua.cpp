#include <lua.hpp>

#include <iostream>
#include <vector>
#include <unordered_map>
#include <charconv>
#include <string_view>
#include <vector>
#include <string>
#include <optional>
#include <format>
#include <chrono>

#include <Visibility.h>

template <typename T>
constexpr T align_up(T value, std::size_t alignment) noexcept {
    return (value + static_cast<T>(alignment) - 1) & ~static_cast<T>(alignment - 1);
}

std::byte* parse_pointer(const char* s) {
    auto value = static_cast<uintptr_t>(std::strtoull(s, nullptr, 16));
    return reinterpret_cast<std::byte*>(value);
}

struct GMLuaCommand {
    uint32_t id;
    uint32_t data_offset;
};

struct CommandBufferHeader {
    uint64_t command_count;
};

struct CommandDataBufferHeader {
    uint32_t next_free_offset;
};

struct StringHash {
    using is_transparent = void;

    size_t operator()(std::string_view sv) const noexcept {
        return std::hash<std::string_view>{}(sv);
    }
};

struct StringEqual {
    using is_transparent = void;

    bool operator()(std::string_view a, std::string_view b) const noexcept {
        return a == b;
    }
};

struct CompiledLuaScript {
    int script_ref;
};

struct LuaScript {
    lua_State* coroutine_state;
    int coroutine_ref;

    std::chrono::steady_clock::time_point suspend_time;
    size_t milliseconds_to_resume;
};

struct GMLuaState {
    lua_State* lua_state;

    std::vector<CompiledLuaScript> compiled_scripts;
    std::unordered_map<std::string, size_t, StringHash, StringEqual> compiled_script_lookup;

    std::vector<LuaScript> scripts;

    std::byte* command_buffer;
    size_t command_buffer_capacity;

    std::byte* command_data_buffer;
    size_t command_data_buffer_capacity;

    std::unordered_map<std::string, std::unordered_map<std::string, int64_t, StringHash, StringEqual>, StringHash, StringEqual> identity_data_lookup;

    std::vector<std::byte*> dynamic_data;

    std::byte* utility_buffer;
    size_t utility_buffer_capacity;

    void signal_growth_if_needed() {
        static constexpr double growth_threshold = 0.8;

        auto* command_header = reinterpret_cast<CommandBufferHeader*>(command_buffer);
        auto* data_header = reinterpret_cast<CommandDataBufferHeader*>(command_data_buffer);

        const size_t command_used = align_up(sizeof(CommandBufferHeader), alignof(GMLuaCommand)) + command_header->command_count * sizeof(GMLuaCommand);
        const size_t data_used = data_header->next_free_offset;
        
        if (command_used >= static_cast<size_t>(static_cast<double>(command_buffer_capacity) * growth_threshold))
            utility_buffer[0] = std::byte{1};

        if (data_used >= static_cast<size_t>(static_cast<double>(command_data_buffer_capacity) * growth_threshold))
            utility_buffer[1] = std::byte{1};
    }

    void push_command(GMLuaCommand command) {
        auto* header = reinterpret_cast<CommandBufferHeader*>(command_buffer);

        std::memcpy(
            command_buffer + align_up(sizeof(CommandBufferHeader), alignof(GMLuaCommand)) + header->command_count * sizeof(GMLuaCommand),
            &command,
            sizeof(command)
        );

        ++header->command_count;
        signal_growth_if_needed();
    }

    uint32_t begin_payload() {
        auto* header = reinterpret_cast<CommandDataBufferHeader*>(command_data_buffer);

        uint32_t offset = header->next_free_offset;

        uint32_t zero = 0;
        std::memcpy(
            command_data_buffer + offset,
            &zero,
            sizeof(zero)
        );

        header->next_free_offset += sizeof(zero);

        signal_growth_if_needed();

        return offset;
    }

    void append_payload(uint32_t payload_offset, const void* data, size_t size) {
        auto* header = reinterpret_cast<CommandDataBufferHeader*>(command_data_buffer);

        std::memcpy(
            command_data_buffer + static_cast<size_t>(header->next_free_offset),
            data,
            size
        );

        header->next_free_offset += size;

        uint32_t payload_size = header->next_free_offset - payload_offset - sizeof(uint32_t);
        std::memcpy(
            command_data_buffer + payload_offset,
            &payload_size,
            sizeof(payload_size)
        );

        signal_growth_if_needed();
    }
};

enum class LuaArgType : uint8_t {
    Id,
    Number,
    String,
    Boolean
};

struct CompiledSignature {
    std::vector<LuaArgType> args;
};

std::vector<GMLuaState> states;
std::vector<CompiledSignature> command_signatures;

std::string last_error;

int gm_dispatch(lua_State* L) {
    uint32_t command_id = static_cast<uint32_t>(lua_tointeger(L, lua_upvalueindex(1)));

    lua_getfield(L, LUA_REGISTRYINDEX, "gmlua_context");
    GMLuaState& state = states[static_cast<size_t>(lua_tonumber(L, -1))];
    lua_pop(L, 1);

    const CompiledSignature& sig = command_signatures[command_id];

    uint32_t payload = state.begin_payload();

    int stack_index = 1;
    for (LuaArgType arg : sig.args) {
        switch (arg) {
            case LuaArgType::Id: {
                int64_t value = lua_tonumber(L, stack_index);
                state.append_payload(payload, &value, sizeof(value));
                break;
            }
            case LuaArgType::Number: {
                double value = lua_tonumber(L, stack_index);
                state.append_payload(payload, &value, sizeof(value));
                break;
            }
            case LuaArgType::Boolean: {
                uint8_t value = lua_toboolean(L, stack_index) ? 1 : 0;
                state.append_payload(payload, &value, sizeof(value));
                break;
            }
            case LuaArgType::String: {
                const char* str = lua_tostring(L, stack_index);
                size_t len = str ? std::strlen(str) + 1 : 1;
                state.append_payload(payload, str ? str : "", len);
                break;
            }
        }

        ++stack_index;
    }

    state.push_command({ command_id, payload });
    return 0;
}

int handle_get(lua_State* L) {
    lua_getfield(L, LUA_REGISTRYINDEX, "gmlua_context");
    GMLuaState& state = states[static_cast<size_t>(lua_tonumber(L, -1))];
    lua_pop(L, 1);

    const char* category = lua_tostring(L, 1);
    const char* name = lua_tostring(L, 2);

    auto category_it = state.identity_data_lookup.find(category);
    if (category_it == state.identity_data_lookup.end()) {
        lua_pushinteger(L, -1);
        return 1;
    }

    auto name_it = category_it->second.find(name);
    if (name_it == category_it->second.end()) {
        lua_pushinteger(L, -1);
        return 1;
    }

    lua_pushinteger(L, name_it->second);

    return 1;
}

int handle_get_data(lua_State* L) {
    lua_getfield(L, LUA_REGISTRYINDEX, "gmlua_context");
    GMLuaState& state = states[static_cast<size_t>(lua_tonumber(L, -1))];
    lua_pop(L, 1);

    size_t identity_id = static_cast<size_t>(lua_tointeger(L, 1));
    std::byte* dynamic_data = state.dynamic_data[identity_id];

    lua_pushlightuserdata(L, static_cast<void*>(dynamic_data));
    return 1;
}

int handle_read_number(lua_State* L) {
    std::byte* dynamic_data = static_cast<std::byte*>(lua_touserdata(L, 1));

    lua_pushnumber(L, *reinterpret_cast<double*>(dynamic_data + lua_tointeger(L, 2)));
    return 1;
}

int handle_read_bool(lua_State* L) {
    std::byte* dynamic_data = static_cast<std::byte*>(lua_touserdata(L, 1));

    lua_pushboolean(L, *reinterpret_cast<uint8_t*>(dynamic_data + lua_tointeger(L, 2)));
    return 1;
}

int gm_print(lua_State* L) {
    int num_args = lua_gettop(L);

    for (int i = 1; i <= num_args; ++i) {
        switch (lua_type(L, i)) {
        case LUA_TSTRING:
            std::cout << lua_tostring(L, i);
            break;
        case LUA_TNUMBER:
            std::cout << lua_tonumber(L, i);
            break;
        case LUA_TBOOLEAN:
            std::cout << (lua_toboolean(L, i) ? "true" : "false");
            break;
        case LUA_TNIL:
            std::cout << "nil";
            break;
        default:
            std::cout << "<" << luaL_typename(L, i) << ">";
            break;
        }

        if (i != num_args)
            std::cout << '\t';
    }

    std::cout << std::endl;

    return 0;
}

int gm_wait(lua_State* L) {
    lua_getfield(L, LUA_REGISTRYINDEX, "gmlua_context");
    GMLuaState& state = states[static_cast<size_t>(lua_tonumber(L, -1))];
    lua_pop(L, 1);

    lua_pushlightuserdata(L, L);
    lua_gettable(L, LUA_REGISTRYINDEX);

    size_t script_id = luaL_checkinteger(L, -1);
    lua_pop(L, 1);
    
    LuaScript& script = state.scripts[script_id];

    script.suspend_time = std::chrono::steady_clock::now();
    script.milliseconds_to_resume = static_cast<size_t>(lua_tointeger(L, 1));

    return lua_yield(L, 0);
}

int panic_handler(lua_State* L) {
    std::cout << lua_tostring(L, -1) << std::endl;
    return 0;
}

inline void script_end(GMLuaState& state) {
    state.push_command({ 0, 4294967295 });
}

struct GMBuffer {
    size_t size;
    std::byte* pointer;
};

std::optional<std::vector<GMBuffer>> parse_descriptor(std::string_view descriptor, size_t expected) {
    std::vector<GMBuffer> entries;

    size_t pos = 0;
    while (pos < descriptor.size()) {
        size_t pipe = descriptor.find('|', pos);
        std::string_view entry = descriptor.substr(
            pos,
            pipe == std::string_view::npos ? std::string_view::npos : pipe - pos
        );

        size_t caret = entry.find('^');
        if (caret == std::string_view::npos) {
            last_error = std::format("Malformed descriptor entry (missing '^'): {}", entry);
            return std::nullopt;
        }

        std::string_view size_str = entry.substr(0, caret);
        std::string_view hex_str = entry.substr(caret + 1);

        if (size_str.empty() || hex_str.empty()) {
            last_error = std::format("Malformed descriptor entry (empty field): {}", entry);
            return std::nullopt;
        }

        size_t size = 0;
        auto size_result = std::from_chars(size_str.data(), size_str.data() + size_str.size(), size);
        if (size_result.ec != std::errc() || size_result.ptr != size_str.data() + size_str.size()) {
            last_error = std::format("Invalid size field: {}", size_str);
            return std::nullopt;
        }

        uintptr_t address = 0;
        auto hex_result = std::from_chars(hex_str.data(), hex_str.data() + hex_str.size(), address, 16);
        if (hex_result.ec != std::errc() || hex_result.ptr != hex_str.data() + hex_str.size()) {
            last_error = std::format("Invalid pointer field: {}", hex_str);
            return std::nullopt;
        }

        entries.push_back({ size, reinterpret_cast<std::byte*>(address) });

        pos = (pipe == std::string_view::npos) ? descriptor.size() : pipe + 1;
    }

    if (entries.size() != expected) {
        last_error = std::format("Descriptor must contain exactly {} buffer(s)", expected);
        return std::nullopt;
    }

    return entries;
}

extern "C" GMLUA_DECLSPEC const char* gmlua_get_last_error() {
    return last_error.c_str();
}

extern "C" GMLUA_DECLSPEC double lua_create(const char* descriptor) {
    lua_State* L = luaL_newstate();
    if (!L) return -1.0;

    luaL_openlibs(L);

    luaL_dostring(L, "package.path = package.path .. ';./lua/?.lua'");

    lua_pushcfunction(L, gm_print);
    lua_setglobal(L, "print");

    lua_pushcfunction(L, gm_wait);
    lua_setglobal(L, "wait");

    lua_pushcfunction(L, handle_get);
    lua_setglobal(L, "handle_get");
    
    lua_pushcfunction(L, handle_get_data);
    lua_setglobal(L, "handle_get_data");

    lua_pushcfunction(L, handle_read_number);
    lua_setglobal(L, "handle_read_number");

    lua_pushcfunction(L, handle_read_bool);
    lua_setglobal(L, "handle_read_bool");

    lua_atpanic(L, panic_handler);

    auto result = parse_descriptor(descriptor, 3);
    if (!result) return -2.0;

    std::vector<GMBuffer>& buffers = result.value();

    std::byte* command_buffer_ptr = buffers[0].pointer;
    CommandBufferHeader command_buffer_header = { 0 };
    std::memcpy(command_buffer_ptr, &command_buffer_header, sizeof(CommandBufferHeader));

    std::byte* command_data_buffer_ptr = buffers[1].pointer;
    CommandDataBufferHeader data_buffer_header = { sizeof(CommandDataBufferHeader) };
    std::memcpy(command_data_buffer_ptr, &data_buffer_header, sizeof(CommandDataBufferHeader));

    states.push_back({
        L,

        {},
        {},

        {},

        command_buffer_ptr,
        buffers[0].size,

        command_data_buffer_ptr,
        buffers[1].size,

        {},

        {},

        buffers[2].pointer,
        buffers[2].size
    });

    command_signatures.emplace_back();

    lua_pushnumber(L, states.size() - 1);
    lua_setfield(L, LUA_REGISTRYINDEX, "gmlua_context");

    return static_cast<double>(states.size() - 1);
}

extern "C" GMLUA_DECLSPEC double lua_destroy(double id) {
    if (id < 0 || id >= states.size()) {
        last_error = "Invalid GMLua id passed to function";
        return -1.0;
    }
    GMLuaState& state = states[static_cast<size_t>(id)];

    for (CompiledLuaScript& script : state.compiled_scripts) {
        luaL_unref(state.lua_state, LUA_REGISTRYINDEX, script.script_ref);
    }

    lua_close(state.lua_state);

    return 0.0;
}

extern "C" GMLUA_DECLSPEC double lua_compile(double id, const char* filename) {
    if (id < 0 || id >= states.size()) {
        last_error = "Invalid GMLua id passed to function";
        return -1.0;
    }
    GMLuaState& state = states[static_cast<size_t>(id)];

    int status = luaL_loadfile(state.lua_state, filename);
    if (status != LUA_OK) {
        last_error = std::format("Load error: {}", lua_tostring(state.lua_state, -1));
        lua_pop(state.lua_state, 1);
        return -2.0;
    }

    CompiledLuaScript& script_slot = state.compiled_scripts.emplace_back();
    state.compiled_script_lookup.insert(std::pair<std::string, size_t>(std::string(filename), state.compiled_scripts.size() - 1));
    script_slot.script_ref = luaL_ref(state.lua_state, LUA_REGISTRYINDEX);

    return state.compiled_scripts.size() - 1;
}

extern "C" GMLUA_DECLSPEC double lua_run(double id, const char* filename) {
    if (id < 0 || id >= states.size()) {
        last_error = "Invalid GMLua id passed to function";
        return -1.0;
    }
    GMLuaState& state = states[static_cast<size_t>(id)];

    auto it = state.compiled_script_lookup.find(filename);
    if (it == state.compiled_script_lookup.end()) {
        lua_compile(id, filename);
        it = state.compiled_script_lookup.find(filename);
    }
    
    lua_State* coroutine_state = lua_newthread(state.lua_state);
    int coroutine_ref = luaL_ref(state.lua_state, LUA_REGISTRYINDEX);

    lua_rawgeti(state.lua_state, LUA_REGISTRYINDEX, state.compiled_scripts[it->second].script_ref);

    lua_xmove(state.lua_state, coroutine_state, 1);

    state.scripts.push_back({
        coroutine_state,
        coroutine_ref,
        {},
        0
    });

    lua_pushlightuserdata(state.lua_state, state.scripts.back().coroutine_state);
    lua_pushinteger(state.lua_state, state.scripts.size() - 1);
    lua_settable(state.lua_state, LUA_REGISTRYINDEX);

    int status = lua_resume(coroutine_state, 0);
    if (status != LUA_OK && status != LUA_YIELD) {
        std::cout << status << std::endl;
        last_error = std::format("Runtime error: {}", lua_tostring(coroutine_state, -1));
        lua_pop(coroutine_state, 1);
        return -2.0;
    }

    if (status == LUA_OK) script_end(state);

    return 0.0;
}

extern "C" GMLUA_DECLSPEC double lua_run_from_id(double id, double script) {
    if (id < 0 || id >= states.size()) {
        last_error = "Invalid GMLua id passed to function";
        return -1.0;
    }
    GMLuaState& state = states[static_cast<size_t>(id)];

    if (script < 0 || script >= state.compiled_scripts.size()) {
        last_error = "Invalid Lua script passed to function";
        return -2.0;
    }

    lua_State* coroutine_state = lua_newthread(state.lua_state);
    int coroutine_ref = luaL_ref(state.lua_state, LUA_REGISTRYINDEX);

    lua_rawgeti(state.lua_state, LUA_REGISTRYINDEX, state.compiled_scripts[static_cast<size_t>(script)].script_ref);

    lua_xmove(state.lua_state, coroutine_state, 1);

    state.scripts.push_back({
        coroutine_state,
        coroutine_ref,
        {},
        0
    });

    lua_pushlightuserdata(state.lua_state, state.scripts.back().coroutine_state);
    lua_pushinteger(state.lua_state, state.scripts.size() - 1);
    lua_settable(state.lua_state, LUA_REGISTRYINDEX);

    int status = lua_resume(coroutine_state, 0);
    if (status != LUA_OK && status != LUA_YIELD) {
        std::cout << status << std::endl;
        last_error = std::format("Runtime error: {}", lua_tostring(coroutine_state, -1));
        lua_pop(coroutine_state, 1);
        return -3.0;
    }

    if (status == LUA_OK) script_end(state);

    return 0.0;
}

std::optional<CompiledSignature> compile_signature(const char* signature) {
    CompiledSignature compiled;

    for (const char* c = signature; *c != '\0'; ++c) {
        switch (*c) {
            case 'i': compiled.args.push_back(LuaArgType::Id); break;
            case 'n': compiled.args.push_back(LuaArgType::Number); break;
            case 'b': compiled.args.push_back(LuaArgType::Boolean); break;
            case 's': compiled.args.push_back(LuaArgType::String); break;
            default:
                last_error = std::format("Unknown signature tag: '{}'", *c);
                return std::nullopt;
        }
    }

    return compiled;
}

extern "C" GMLUA_DECLSPEC double lua_add_function(double id, const char* name, const char* signature) {
    if (id < 0 || id >= states.size()) {
        last_error = "Invalid GMLua id passed to function";
        return -1.0;
    }

    lua_State* L = states[static_cast<size_t>(id)].lua_state;

    auto result = compile_signature(signature);
    if (!result) return -2.0;

    command_signatures.push_back(result.value());
    size_t command_id = command_signatures.size() - 1;

    lua_pushinteger(L, static_cast<lua_Integer>(command_id));
    lua_pushcclosure(L, gm_dispatch, 1);
    lua_setglobal(L, name);

    return command_id;
}

enum class BufferType {
    COMMAND_BUFFER,
    COMMAND_DATA_BUFFER
};

extern "C" GMLUA_DECLSPEC double gmlua_rebind_buffer(double id, const char* descriptor, double type) {
    if (id < 0 || id >= states.size()) {
        last_error = "Invalid GMLua id passed to function";
        return -1.0;
    }

    GMLuaState& state = states[static_cast<size_t>(id)];

    auto result = parse_descriptor(descriptor, 1);
    if (!result) return -2.0;

    GMBuffer buffer = result.value()[0];

    switch (static_cast<BufferType>(type)) {
    case BufferType::COMMAND_BUFFER:
        state.command_buffer = buffer.pointer;
        state.command_buffer_capacity = buffer.size;
        break;
    case BufferType::COMMAND_DATA_BUFFER:
        state.command_data_buffer = buffer.pointer;
        state.command_data_buffer_capacity = buffer.size;
        break;
    }

    return 0;
}

extern "C" GMLUA_DECLSPEC double gmlua_register_category(double id, const char* category) {
    if (id < 0 || id >= states.size()) {
        last_error = "Invalid GMLua id passed to function";
        return -1.0;
    }

    GMLuaState& state = states[static_cast<size_t>(id)];

    state.identity_data_lookup.insert({ std::string(category), {} });

    return 0.0;
}

struct HandleData {
    std::string category;
    std::string name;
};

HandleData parse_handle_data(const char* handle_data) {
    HandleData result;

    bool is_name = false;
    while (*handle_data) {
        const char c = *handle_data;
        ++handle_data;
        if (c == '|') {
            is_name = true;
            continue;
        }
        if (is_name)
            result.name.push_back(c);
        else
            result.category.push_back(c);
    }

    return result;
}

extern "C" GMLUA_DECLSPEC double gmlua_register_handle(double id, const char* handle_data, const char* descriptor) {
    if (id < 0 || id >= states.size()) {
        last_error = "Invalid GMLua id passed to function";
        return -1.0;
    }

    GMLuaState& state = states[static_cast<size_t>(id)];

    HandleData parsed_handle_data = parse_handle_data(handle_data);

    auto result = parse_descriptor(descriptor, 1);
    if (!result) return -2.0;

    auto it = state.identity_data_lookup.find(parsed_handle_data.category);
    if (it == state.identity_data_lookup.end()) {
        last_error = "Invalid category";
        return -3.0;
    }

    state.dynamic_data.push_back(result.value()[0].pointer);
    int64_t handle = state.dynamic_data.size() - 1;
    it->second.try_emplace(parsed_handle_data.name, handle);

    return static_cast<double>(handle);
}

extern "C" GMLUA_DECLSPEC double gmlua_get_existing_handle(double id, const char* category, const char* name) {
    if (id < 0 || id >= states.size()) {
        last_error = "Invalid GMLua id passed to function";
        return -2.0;
    }

    GMLuaState& state = states[static_cast<size_t>(id)];

    auto category_it = state.identity_data_lookup.find(category);
    if (category_it == state.identity_data_lookup.end()) {
        return -3.0;
    }

    auto& handles = category_it->second;

    auto existing = handles.find(name);
    if (existing != handles.end()) {
        return static_cast<double>(existing->second);
    }

    return -1.0;
}

extern "C" GMLUA_DECLSPEC double gmlua_check_suspensions(double id) {
    if (id < 0 || id >= states.size()) {
        last_error = "Invalid GMLua id passed to function";
        return -1.0;
    }

    GMLuaState& state = states[static_cast<size_t>(id)];

    for (auto it = state.scripts.begin(); it != state.scripts.end(); ) {
        LuaScript& script = *it;

        auto elapsed = std::chrono::steady_clock::now() - script.suspend_time;

        if (elapsed < std::chrono::milliseconds(script.milliseconds_to_resume)) {
            ++it;
            continue;
        }

        int status = lua_resume(script.coroutine_state, 0);
        switch (status) {
        case LUA_YIELD:
            ++it;
            break;
        case LUA_OK:
            luaL_unref(
                state.lua_state,
                LUA_REGISTRYINDEX,
                script.coroutine_ref
            );

            lua_pushlightuserdata(state.lua_state, script.coroutine_state);
            lua_pushnil(state.lua_state);
            lua_settable(state.lua_state, LUA_REGISTRYINDEX);

            it = state.scripts.erase(it);

            script_end(state);

            break;
        default:
            last_error = std::format(
                "Runtime error: {}",
                lua_tostring(script.coroutine_state, -1)
            );

            lua_pop(script.coroutine_state, 1);

            luaL_unref(
                state.lua_state,
                LUA_REGISTRYINDEX,
                script.coroutine_ref
            );

            lua_pushlightuserdata(state.lua_state, script.coroutine_state);
            lua_pushnil(state.lua_state);
            lua_settable(state.lua_state, LUA_REGISTRYINDEX);

            it = state.scripts.erase(it);
            return -2.0;
        }
    }

    return 0.0;
}