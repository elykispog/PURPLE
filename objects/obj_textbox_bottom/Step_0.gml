if (keyboard_check_pressed(global.key_confirm)) {
    if (charCount < string_length(text[page])) {
        charCount = string_length(text[page]);
    } else {
        if (page + 1 < array_length(text)) {
            page++;
            charCount = 0;
			
        } else {
            global.cutscene_active = false;
            creator.alarm[1] = 1;
            instance_destroy();
        }
    }
}