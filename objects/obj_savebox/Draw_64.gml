var gx = display_get_gui_width() * 0.5;
var gy = display_get_gui_height() * 0.5;

var centeredX = gx - sprite_get_width(spr_savebox) * 0.5;
var centeredY = gy - sprite_get_height(spr_savebox) * 0.5

draw_sprite(
    spr_savebox,
    0,
    centeredX,
    centeredY
);

draw_set_font(global.basic_font);
draw_set_valign(fa_top);

var rowY = centeredY + yBuffer;
var leftEdge = centeredX + xBuffer;
var rightEdge = centeredX + xBuffer + boxWidth;

draw_set_halign(fa_left);
draw_text(leftEdge, rowY, "SETH");
draw_text(leftEdge, rowY + rowHeight, "Ruins - " + saveLocation);

draw_set_halign(fa_center);
draw_text(leftEdge + colWidth * 1.5, rowY, "LV " + string(global.level));

draw_set_halign(fa_right);
draw_text(rightEdge, rowY, string(global.timePlayed));

var bottomEdge = centeredY + yBuffer + boxHeight;

var centerX = leftEdge + boxWidth * 0.5;
var leftShift = 60;
centerX -= leftShift;

var optionGap = 60;
draw_set_valign(fa_bottom);
draw_set_halign(fa_right);
draw_text(centerX - optionGap, bottomEdge, "Save");
draw_set_halign(fa_left);
draw_text(centerX + optionGap, bottomEdge, "Return");