_textbox = noone;

dialogue = "";

enum DialogueBox {
	Top,
	Bottom
}

interact = function() {
    if (_textbox == noone) {
		var textbox_type = DialogueBox.Bottom;
		
		_textbox = instance_create_layer(x, y, "Text", obj_textbox, {
			dialogue_tree: global.dialogues[$ dialogue],
			node_key: "start",
			type: textbox_type,
			creator: id,
		});

        obj_player.freeze();
    }
};