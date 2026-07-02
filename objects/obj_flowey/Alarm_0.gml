_textbox = noone;

dialogue = "";


    if (_textbox == noone) {
		var textbox_type = DialogueBox.Bottom;
		
		_textbox = instance_create_layer(x, y, "Text", obj_textbox, {
			dialogue_tree: global.dialogues[$ dialogue],
			node_key: "start",
			type: textbox_type,
			creator: id,
		});

        global.cutscene_active = true;
    
};