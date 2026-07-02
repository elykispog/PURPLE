xBuffer = 20;
yBuffer = 15;

boxWidth = sprite_get_width(spr_savebox) - (2 * xBuffer);
boxHeight = sprite_get_height(spr_savebox) - (2 * yBuffer);

colWidth = boxWidth / 3;
rowHeight = 50;

global.cutscene_active = true;