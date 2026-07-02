var gx = display_get_gui_width() * 0.5;
var centeredX = gx - sprite_get_width(spr_textbox) * 0.5;

draw_sprite(
    spr_textbox,
    0,
    centeredX,
    drawOffset
);

draw_set_font(global.basic_font);

if (choosing) {
    var boxH = sprite_get_height(spr_textbox);
    var boxW = boxWidth;

    var left = centeredX + xBuffer;
    var top = drawOffset;
    var right = left + boxW;
    var bottom = top + boxH;

    var margin = 40;

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    for (var i = 0; i < choiceCount; i++) {
        var px, py;

        switch (choiceCount) {
            case 2:
            {
                var slice = boxW / 2;
                px = left + slice * i + slice * 0.5;
                py = top + boxH * 0.5;
                break;
            }
			
            case 3:
            {
                switch (i) {
                    case 0:
						px = left + boxW * 0.25;
						py = bottom - margin;
						break;

					case 1:
						px = left + boxW * 0.5;
						py = top + margin;
						break;

					case 2:
						px = left + boxW * 0.75;
						py = bottom - margin;
						break;
                }
                break;
            }
			
            case 4:
            {
                switch (i) {
                    case 0:
                        px = left + boxW * 0.25;
                        py = top + margin;
                        break;

                    case 1:
                        px = left + boxW * 0.75;
                        py = top + margin;
                        break;

                    case 2:
                        px = left + boxW * 0.25;
                        py = bottom - margin;
                        break;

                    case 3:
                        px = left + boxW * 0.75;
                        py = bottom - margin;
                        break;
                }
                break;
            }
			
            default:
            {
                var slice = boxW / choiceCount;
                px = left + slice * i + slice * 0.5;
                py = top + boxH * 0.5;
            }
        }
		
        var wrapWidth = boxW * 0.4;
        var wrapped = wrap_text(dialogue.choices[i].text, wrapWidth);
		
        var lineHeight = string_height("A");
        var startY = py - (array_length(wrapped) - 1) * lineHeight * 0.5;

        for (var l = 0; l < array_length(wrapped); l++) {
            draw_text_transformed(px, startY + l * lineHeight, wrapped[l], 0.9, 0.9, 0);
        }

        if (selectedChoice == i) {
            draw_sprite(
                soul,
                0,
                px - wrapWidth * 0.5 - 20,
                py - 8
            );
        }
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
	
	exit;
}

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