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

function load_dialogue_data(_room) {
    global.dialogues = {};

    var file = file_find_first("dialogue/" + _room + "/*.json", fa_archive);
	
    while (file != "") {
        var path = "dialogue/" + _room + "/" + file;

        var f = file_text_open_read(path);
		var text = "";

		while (!file_text_eof(f)) {
			text += file_text_read_string(f);
			file_text_readln(f);
		}

		file_text_close(f);
		
        var data = json_parse(text);

        var file_key = filename_change_ext(file, "");

        var ns = get_dialogue_namespace(data, file_key);
		
		if (is_struct(data)) {
			variable_struct_remove(data, "namespace");
		}

		global.dialogues[$ file_key] = normalize_dialogue(data, ns);

        file = file_find_next();
    }

    file_find_close();
}

function load_localized(_room) {
    var file = file_find_first("i18n/" + _room + "/" + global.localization + "/*.json", fa_archive);

    while (file != "") {
        var path = "i18n/" + _room + "/" + global.localization + "/" + file;

        var f = file_text_open_read(path);
		var text = "";

		while (!file_text_eof(f)) {
			text += file_text_read_string(f);
			file_text_readln(f);
		}

		file_text_close(f);
		
        var data = json_parse(text);

        var file_key = filename_change_ext(file, "");
		
        var keys = variable_struct_get_names(data);
		for (var i = 0; i < array_length(keys); i++) {
			var k = keys[i];
			var combined_key = file_key + "." + string(k);

			global.localized[$ combined_key] = variable_struct_get(data, k);
		}

        file = file_find_next();
    }

    file_find_close();
}

function load_dialogue(_room) {
    load_dialogue_data(_room);
    load_localized(_room);
}

function get_text(_key) {
	var text = global.localized[$ _key];
	return text;
}