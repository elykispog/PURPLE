_textbox = noone;

dialogue = "";

enum DialogueBox {
	Top,
	Bottom
}

interact = function() {
    if (_textbox == noone) {
		var textbox_type = DialogueBox.Bottom;
		
		show_debug_message("Lookup: " + dialogue);
show_debug_message("global.dialogues exists: " + string(global.dialogues != undefined));
show_debug_message("Exists now: " + string(global.dialogues[$ dialogue] != undefined));

var keys = variable_struct_get_names(global.dialogues);
show_debug_message("Dialogue count: " + string(array_length(keys)));

for (var i = 0; i < array_length(keys); i++) {
    show_debug_message("  " + string(keys[i]));
}
		
		_textbox = instance_create_layer(x, y, "Text", obj_textbox, {
			dialogue_tree: global.dialogues[$ dialogue],
			node_key: "start",
			type: textbox_type,
			creator: id,
		});

        obj_player.freeze();
    }
};