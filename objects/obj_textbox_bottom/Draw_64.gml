var vx = camera_get_view_x(view_camera[0]);

var vy = camera_get_view_y(view_camera[0]);
draw_sprite(spr_textbox, 0, 50,475);



draw_set_font(fnt_basic);

if(charCount < string_length(text[page])){

charCount += 1;
if creator.is_flowey = true{
audio_play_sound(snd_floweytalk1, 0, 0, 1.0, undefined, 1.0);
}
if creator.is_flowey = false{
audio_play_sound(snd_txt1, 0, 0, 1.0, undefined, 1.0);
}
}
textPart = string_copy(text[page], 1, ceil(charCount));


draw_text_ext(50+xBuffer,475+yBuffer, textPart, stringHeight, boxWidth);


