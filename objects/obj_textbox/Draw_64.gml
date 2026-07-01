var gx = display_get_gui_width() * 0.5;
var centeredX = gx - sprite_get_width(spr_textbox) * 0.5;

draw_sprite(
    spr_textbox,
    0,
    centeredX,
    drawOffset
);

draw_set_font(global.basic_font);

if (charCount < string_length(wrappedText)) {
	++charCount;
    if (variable_struct_exists(dialogue, "sound")) {
        audio_play_sound(dialogue.sound, 0, false, 1.0);
    } else {
        audio_play_sound(snd_txt1, 0, false, 1.0);
	}
}

textPart = string_copy(wrappedText, 1, charCount);

draw_text_ext(
    centeredX + xBuffer,
    drawOffset + yBuffer,
    textPart,
    stringHeight,
    boxWidth
);

if (!variable_struct_exists(dialogue, "choices")) exit;

if (page == array_length(dialogue.pages) - 1) {
    var sliceWidth = boxWidth / choiceCount;
    var boxMidY = drawOffset + sprite_get_height(spr_textbox) * 0.5;
	
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    for (var i = 0; i < choiceCount; i++) {
        var sliceMidX = centeredX + xBuffer + sliceWidth * i + sliceWidth * 0.5;
        draw_text(sliceMidX, boxMidY, dialogue.choices[i].text);
		if (selectedChoice == i) {
			draw_sprite(soul, 0, sliceMidX - 30, boxMidY - 8);
		}
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}