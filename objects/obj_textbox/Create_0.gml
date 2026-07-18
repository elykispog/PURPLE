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
                var replacement = global.localization_system.get_text(token) ?? ("{" + token + "}");

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

function wrap_text(_text, _width, _firstPrefix = "") {
    var words = string_split(_text, " ");
    var lines = [];

    var current = "";
    var firstLine = true;

    for (var i = 0; i < array_length(words); i++) {
        var word = words[i];
        var test = (current == "") ? word : current + " " + word;

        var prefix = firstLine ? _firstPrefix : "";

        if (current != "" && string_width(prefix + test) > _width) {
            array_push(lines, current);
            current = word;
            firstLine = false;
        } else {
            current = test;
        }
    }

    if (current != "") {
        array_push(lines, current);
    }

    return lines;
}

function dialogue_load_page() {
    var page_text = resolve_localized(dialogue.pages[page]);

    wrappedText = "";

    var paragraphs = string_split(page_text, "\n");

    for (var p = 0; p < array_length(paragraphs); p++) {
        var lines = wrap_text(paragraphs[p], boxWidth, "* ");

        for (var i = 0; i < array_length(lines); i++) {
            if (i == 0) {
                wrappedText += "* " + lines[i];
            } else {
                wrappedText += "" + lines[i];
            }

            if (i < array_length(lines) - 1 || p < array_length(paragraphs) - 1) {
                wrappedText += "\n";
            }
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
stringHeight = 40;

drawOffset = (type == DialogueBox.Top) ? 10 : 325;

draw_set_font(global.basic_font);

dialogue_load_node(node_key);