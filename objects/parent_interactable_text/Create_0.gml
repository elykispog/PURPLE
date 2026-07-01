_textbox = noone;

dialogue = {
    pages: [""]
};

enum DialogueBox {
	Top,
	Bottom
}

interact = function() {
    if (_textbox == noone) {
		var textbox_type = DialogueBox.Bottom;
		
		if (variable_struct_exists(dialogue, "type")) {
			textbox_type = dialogue.type;
		}
		
		_textbox = instance_create_layer(x, y, "Text", obj_textbox, {
			dialogue_tree: dialogue,
			node_key: "start",
			type: textbox_type,
			creator: id,
		});

        global.cutscene_active = true;
    }
};