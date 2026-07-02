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

function load_dialogue_directory(_base, _relative) {
    var files = [];
    var dirs = [];

    var item = file_find_first(_base + _relative + "*", fa_archive | fa_directory);

    while (item != "") {
        var full_path = _base + _relative + item;

        if (directory_exists(full_path)) {
            array_push(dirs, item);
        } else if (filename_ext(item) == ".json") {
            array_push(files, item);
        }

        item = file_find_next();
    }

    file_find_close();
	
    for (var i = 0; i < array_length(files); i++) {
		var file = files[i];

		var relative_path = _relative + file;
		var full_path = _base + relative_path;

		var f = file_text_open_read(full_path);
		var text = "";

		while (!file_text_eof(f)) {
			text += file_text_read_string(f);
			file_text_readln(f);
		}

		file_text_close(f);

		var data = json_parse(text);

		var file_key = filename_change_ext(relative_path, "");
		file_key = string_replace_all(file_key, "\\", ".");
		file_key = string_replace_all(file_key, "/", ".");

		var ns = get_dialogue_namespace(data, file_key);

		if (is_struct(data)) {
			variable_struct_remove(data, "namespace");
		}

		global.dialogues[$ file_key] = normalize_dialogue(data, ns);
	}
	
    for (var i = 0; i < array_length(dirs); i++) {
        load_dialogue_directory(_base, _relative + dirs[i] + "/");
    }
}

function load_dialogue_data(_room) {
    global.dialogues = {};
    load_dialogue_directory("dialogue/" + _room + "/", "");
}

function load_localized_directory(_base, _relative) {
    var files = [];
    var dirs = [];

    var item = file_find_first(_base + _relative + "*", fa_archive | fa_directory);

    while (item != "") {
        var full_path = _base + _relative + item;

        if (directory_exists(full_path)) {
            array_push(dirs, item);
        } else if (filename_ext(item) == ".json") {
            array_push(files, item);
        }

        item = file_find_next();
    }

    file_find_close();
	
    for (var i = 0; i < array_length(files); i++) {
		var file = files[i];

		var relative_path = _relative + file;
		var full_path = _base + relative_path;

		var f = file_text_open_read(full_path);
		var text = "";

		while (!file_text_eof(f)) {
			text += file_text_read_string(f);
			file_text_readln(f);
		}

		file_text_close(f);

		var data = json_parse(text);

		var file_key = filename_change_ext(relative_path, "");
		file_key = string_replace_all(file_key, "\\", ".");
		file_key = string_replace_all(file_key, "/", ".");

		var keys = variable_struct_get_names(data);

		for (var j = 0; j < array_length(keys); j++) {
			var k = keys[j];
			global.localized[$ file_key + "." + string(k)] = variable_struct_get(data, k);
		}
	}
	
    for (var i = 0; i < array_length(dirs); i++) {
        load_localized_directory(_base, _relative + dirs[i] + "/");
    }
}

function load_localized(_room) {
    load_localized_directory("i18n/" + _room + "/" + global.localization + "/", "");
}

function load_dialogue(_room) {
    load_dialogue_data(_room);
    load_localized(_room);
}

function get_text(_key) {
	var text = global.localized[$ _key];
	return text;
}