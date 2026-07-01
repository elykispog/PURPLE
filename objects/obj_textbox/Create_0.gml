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
    wrappedLines = wrap_text(dialogue.pages[page], boxWidth);
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
}

xBuffer = 35;
yBuffer = 30;
boxWidth = sprite_get_width(spr_textbox) - (2*xBuffer);
stringHeight = 50;

drawOffset = (type == DialogueBox.Top) ? 10 : 325;

dialogue_load_node(node_key);