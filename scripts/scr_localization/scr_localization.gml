function normalize_dialogue_string(_s, _prefix) {
    var result = "";
    var i = 1;

    while (i <= string_length(_s)) {
        var c = string_char_at(_s, i);

        if (c == "{") {
            var j = i + 1;
            var token = "";

            while (j <= string_length(_s)) {
                var c2 = string_char_at(_s, j);

                if (c2 == "}") break;

                token += c2;
                j++;
            }

            if (token != "") {
                if (string_copy(token, 1, string_length(_prefix + ".")) != _prefix + ".") {
					token = _prefix + "." + token;
				}
                result += "{" + token + "}";
            } else {
                result += "{}";
            }
			
            i = j + 1;
        }
        else {
            result += c;
            i++;
        }
    }

    return result;
}

function normalize_dialogue(_data, _prefix) {
    if (is_struct(_data)) {
        var keys = variable_struct_get_names(_data);
        var i = 0;

        while (i < array_length(keys)) {
            var k = keys[i];
            var v = variable_struct_get(_data, k);

            variable_struct_set(_data, k, normalize_dialogue(v, _prefix));

            i++;
        }

        return _data;
    }

    if (is_array(_data)) {
        var arr = _data;
        var len = array_length(arr);

        for (var i = 0; i < len; i++) {
            arr[i] = normalize_dialogue(arr[i], _prefix);
        }

        return arr;
    }

    if (is_string(_data)) {
        return normalize_dialogue_string(_data, _prefix);
    }

    return _data;
}

function get_dialogue_namespace(_data, _fallback) {
    if (is_struct(_data) && variable_struct_exists(_data, "namespace")) {
        var ns = _data.namespace;

        if (is_string(ns) && ns != "") {
            return ns;
        }
    }

    return _fallback;
}

function LocalizationSystem() constructor {
	__dialogues = {};
	__localized = {};
	
	static load_dialogue_data = function(_area) {
		__dialogues = {};
	
		var _base = "dialogue/" + _area + "/";
		var _files = file_list_recursive(_base, ".json");
	
		for (var i = 0; i < array_length(_files); ++i) {
			var _file = _files[i];
			
			var _full_path = _base + _file;
			var _json_data = json_parse(file_read(_full_path));
			
			var _file_key = filename_change_ext(_file, "");
			_file_key = string_replace_all(_file_key, "\\", ".");
			_file_key = string_replace_all(_file_key, "/", ".");
			
			var _namespace = get_dialogue_namespace(_json_data, _file_key);
			
			if (is_struct(_json_data)) {
				variable_struct_remove(_json_data, "namespace");
			}
			
			__dialogues[$ _file_key] = normalize_dialogue(_json_data, _namespace);
		}
	}

	static load_localized = function(_area) {
		__localized = {};
		
		var _base = "i18n/" + _area + "/" + global.localization + "/";
		var _files = file_list_recursive(_base, ".json");

		for (var i = 0; i < array_length(_files); ++i) {
			var _file = _files[i];

			var _data = json_parse(file_read(_base + _file));
			
			var _file_key = filename_change_ext(_file, "");
			_file_key = string_replace_all(_file_key, "\\", ".");
			_file_key = string_replace_all(_file_key, "/", ".");
			
			var _keys = variable_struct_get_names(_data);
			
			for (var j = 0; j < array_length(_keys); ++j) {
				var _key = _keys[j];
				__localized[$ _file_key + "." + string(_key)] = variable_struct_get(_data, _key);
			}
		}
	}

	static load_dialogue = function(_area) {
		load_dialogue_data(_area);
		load_localized(_area);
	}

	static get_text = function(_key) {
		return __localized[$ _key];
	}
	
	static get_dialogue = function(_dialogue) {
		return __dialogues[$ _dialogue];
	}
}

function initalize_localization_system() {
	global.localization_system = new LocalizationSystem();
}