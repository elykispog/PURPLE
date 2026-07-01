draw_sprite(spr_textbox, 0, x,y);



draw_set_font(fnt_basic);

if(charCount < string_length(text[page])){

charCount += 1;
}
textPart = string_copy(text[page], 1, ceil(charCount));
draw_text_ext(x,y, textPart, stringHeight, boxWidth);

