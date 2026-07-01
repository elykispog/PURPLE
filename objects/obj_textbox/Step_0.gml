if (keyboard_check_pressed(global.key_cancel)) {
    if (charCount < string_length(wrappedText)) {
        charCount = string_length(wrappedText);
        exit;
    }
} else if (keyboard_check_pressed(global.key_confirm)) {
    if (page + 1 < array_length(dialogue.pages)) {
        page++;
        dialogue_load_page();
    } else if (choiceCount > 0) {
        // a choice was made; run its action/branch instead of ending
        var _choice = dialogue.choices[selectedChoice];

        if (variable_struct_exists(dialogue, "on_choice")) {
            if (is_callable(dialogue.on_choice)) {
                dialogue.on_choice(_choice.text);
            }
        }
        if (variable_struct_exists(_choice, "action")) {
            if (is_callable(_choice.action)) {
                _choice.action();
            }
        }

        if (variable_struct_exists(_choice, "next") && _choice.next != "") {
            dialogue_load_node(_choice.next); // Branch to next ndoe
        } else {
            // no "next"
            global.cutscene_active = false;
            creator.alarm[1] = 1;
            if (variable_struct_exists(dialogue, "on_end")) {
                if (is_callable(dialogue.on_end)) dialogue.on_end();
            }
            instance_destroy();
        }
    } else {
		// no choices
        charCount = string_length(wrappedText);
        global.cutscene_active = false;
        creator.alarm[1] = 1;
        if (variable_struct_exists(dialogue, "on_end")) {
            if (is_callable(dialogue.on_end)) dialogue.on_end();
        }
        instance_destroy();
    }
} else if (keyboard_check_pressed(global.key_left) || keyboard_check_pressed(global.key_right)) {
	if (page == array_length(dialogue.pages) - 1 && choiceCount > 0) {
		audio_play_sound(snd_txt1, 0, false, 1.0);
		selectedChoice += keyboard_check_pressed(global.key_right) ? 1 : -1;
		if (selectedChoice < 0)
			selectedChoice = choiceCount - 1;
		else if (selectedChoice >= choiceCount)
			selectedChoice = 0;
	}
}