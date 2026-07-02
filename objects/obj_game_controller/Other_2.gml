global.cutscene_active = false;

global.key_up = vk_up;
global.key_down = vk_down;
global.key_left = vk_left;
global.key_right = vk_right;

global.key_confirm = ord("Z");
global.key_cancel = ord("X");
global.key_menu = ord("C");

global.level = 1;
global.timePlayed = 0;
global.timeStarted = current_time;
global.currentSaveSlot = 0;

global.basic_font = font_add_sprite_ext(spr_font, "gyjqpW%#m&Mw$Q*\\/XIohNc4xBG36Ant7Cefv51JTK0RHaO9PUl28izsb@?DVYFESLudrkZ+>}{<_~=-])[(!^\";,:.|'`", false, 1);

global.localization = "en";

global.dialogues = {};
global.localized = {};

display_set_gui_size(640, 480);