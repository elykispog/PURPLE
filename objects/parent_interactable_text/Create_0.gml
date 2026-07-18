_textbox = noone;

dialogue = "";

enum DialogueBox {
	Top,
	Bottom
}

interact = function() {
    if (_textbox == noone) {
		var textbox_type = DialogueBox.Bottom;
		
		show_debug_message(string(global.localization_system.get_dialogue(dialogue)));
		
		_textbox = instance_create_layer(x, y, "Text", obj_textbox, {
			dialogue_tree: global.localization_system.get_dialogue(dialogue),
			node_key: "start",
			type: textbox_type,
			creator: id,
		});

        obj_player.freeze();
    }
};