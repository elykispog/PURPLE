function resolve_localized(_s) {
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
                var replacement = global.localized[$ token];

                if (replacement == undefined) {
                    replacement = "{" + token + "}";
                }

                result += replacement;
            }

            i = j; // skip closing }
        }
        else {
            result += c;
        }

        i++;
    }

    return result;
}

function prefix_lines(_s, _prefix) {
    var lines = string_split(_s, "\n");
    var result = "";

    for (var i = 0; i < array_length(lines); i++) {
        result += _prefix + lines[i];

        if (i < array_length(lines) - 1) {
            result += "\n";
        }
    }

    return result;
}

function wrap_text(_text, _width) {
	var words = string_split(_text, " ");
    var lines = [];
    var current = "";
    for (var i = 0; i < array_length(words); i++) {
        var test = (current == "") ? words[i] : current + " " + words[i];
        if (string_width(test) > _width) {
            array_push(lines, current);
            current = words[i];
        } else {
            current = test;
        }
    }
    array_push(lines, current);
    return lines;
}

function dialogue_load_page() {
    var page_text = resolve_localized(dialogue.pages[page]);

	wrappedLines = wrap_text(page_text, boxWidth);

	for (var i = 0; i < array_length(wrappedLines); i++) {
		wrappedLines[i] = "* " + wrappedLines[i];
	}

	wrappedText = "";

	for (var i = 0; i < array_length(wrappedLines); i++) {
		wrappedText += wrappedLines[i];

		if (i < array_length(wrappedLines) - 1) {
			wrappedText += "\n";
		}
	}
    charCount = 0;
}

function dialogue_load_node(_key) {
    node_key = _key;
    dialogue = dialogue_tree[$node_key];
    page = 0;
    dialogue_load_page();

    choiceCount = variable_struct_exists(dialogue, "choices") ? array_length(dialogue.choices) : 0;
    selectedChoice = 0;
	choosing = false;
}

xBuffer = 25;
yBuffer = 20;
boxWidth = sprite_get_width(spr_textbox) - (2*xBuffer);
stringHeight = 50;

drawOffset = (type == DialogueBox.Top) ? 10 : 325;

dialogue_load_node(node_key);