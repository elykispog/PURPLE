if (frozen) exit;

if (keyboard_check_pressed(global.key_left)) {
	sprite_index = lsprite;
	image_index = 1;

	image_speed = 1;
}
else if (keyboard_check_released(global.key_left)) {
	sprite_index = lsprite;
	image_index = 0;

	image_speed = 0;
}
else if (keyboard_check_pressed(global.key_right)) {
	sprite_index = rsprite;
	image_index = 1;

	image_speed = 1;
}
else if (keyboard_check_released(global.key_right)) {
	sprite_index = rsprite;
	image_index = 0;

	image_speed = 0;
}
else if (keyboard_check_pressed(global.key_up)) {
	sprite_index = usprite;
	image_index = 1;

	image_speed = 1;
}
else if (keyboard_check_released(global.key_up)) {
	sprite_index = usprite;
	image_index = 0;

	image_speed = 0;
}
else if (keyboard_check_pressed(global.key_down)) {
	sprite_index = dsprite;
	image_index = 1;

	image_speed = 1;
}
else if (keyboard_check_released(global.key_down)) {
	sprite_index = dsprite;
	image_index = 0;

	image_speed = 0;
}