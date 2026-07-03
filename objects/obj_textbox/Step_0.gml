if (keyboard_check_pressed(global.key_cancel)) {
    if (!choosing && charCount < string_length(wrappedText)) {
        charCount = string_length(wrappedText);
        exit;
    }
}

if (keyboard_check_pressed(global.key_confirm)) {
    if (!choosing) {
        // Still typing
        if (charCount != string_length(wrappedText))
            exit;

        // Next dialogue page
        if (page < array_length(dialogue.pages) - 1) {
            page++;
            dialogue_load_page();
        }
        else {
            // Last page reached
            if (choiceCount > 0) {
                choosing = true;
            }
            else {
                global.cutscene_active = false;
                creator.alarm[1] = 1;

                if (variable_struct_exists(dialogue, "on_end")) {
                    if (is_callable(dialogue.on_end))
                        dialogue.on_end();
                }

                instance_destroy();
            }
        }
    }
    else {
        // We're choosing
        var _choice = dialogue.choices[selectedChoice];

        if (variable_struct_exists(dialogue, "on_choice")) {
            if (is_callable(dialogue.on_choice))
                dialogue.on_choice(_choice.text);
        }

        if (variable_struct_exists(_choice, "action")) {
            if (is_callable(_choice.action))
                _choice.action();
        }

        if (variable_struct_exists(_choice, "next") && _choice.next != "") {
            dialogue_load_node(_choice.next);
        }
        else {
            global.cutscene_active = false;
            creator.alarm[1] = 1;

            if (variable_struct_exists(dialogue, "on_end")) {
                if (is_callable(dialogue.on_end))
                    dialogue.on_end();
            }

            instance_destroy();
        }
    }
}

if (choosing) {
    var old = selectedChoice;

    if (choiceCount == 4) {
        if (keyboard_check_pressed(global.key_left)) {
            if (selectedChoice == 1) selectedChoice = 0;
            else if (selectedChoice == 3) selectedChoice = 2;
        }

        if (keyboard_check_pressed(global.key_right)) {
            if (selectedChoice == 0) selectedChoice = 1;
            else if (selectedChoice == 2) selectedChoice = 3;
        }

        if (keyboard_check_pressed(global.key_up)) {
            if (selectedChoice == 2) selectedChoice = 0;
            else if (selectedChoice == 3) selectedChoice = 1;
        }

        if (keyboard_check_pressed(global.key_down)) {
            if (selectedChoice == 0) selectedChoice = 2;
            else if (selectedChoice == 1) selectedChoice = 3;
        }
    }
    else {
        if (keyboard_check_pressed(global.key_left)) {
            selectedChoice--;
            if (selectedChoice < 0)
                selectedChoice = choiceCount - 1;
        }

        if (keyboard_check_pressed(global.key_right)) {
            selectedChoice++;
            if (selectedChoice >= choiceCount)
                selectedChoice = 0;
        }
    }

    if (selectedChoice != old) {
        audio_play_sound(snd_txt, 0, false);
    }
}