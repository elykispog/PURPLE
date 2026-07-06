// 1. Get input
var _horizontal_input = keyboard_check(global.key_right) - keyboard_check(global.key_left);
var _vertical_input = keyboard_check(global.key_down) - keyboard_check(global.key_up);

// 2. Movement/Interaction
if (!frozen) {
	if (_vertical_input > 0) facing = Facing.Down;
	if (_vertical_input < 0) facing = Facing.Up;
	if (_horizontal_input > 0) facing = Facing.Right;
	if (_horizontal_input < 0) facing = Facing.Left;
	
	var interact_x = (bbox_left + bbox_right) * 0.5;
	var interact_y = bbox_bottom;

	switch (facing) {
		case Facing.Up: interact_y -= 16; break;
		case Facing.Down: interact_y += 8;  break;
		case Facing.Left: interact_x -= 12; break;
		case Facing.Right: interact_x += 12; break;
	}

	// Find an interactable at that point
	var target = instance_position(interact_x, interact_y, parent_interactable);
	
	if (target != noone) {
		if (keyboard_check_pressed(global.key_confirm)) {
			target.interact();
			exit;
		}
	}
	
    var _spd = 3;
    var _hsp = _horizontal_input * _spd;
    var _vsp = _vertical_input * _spd;
	
    move_and_collide(_hsp, 0, obj_modularHitbox);
	move_and_collide(0, _vsp, obj_modularHitbox);

    // 3. Animation and Sprite Management
    if (_horizontal_input == 0 && _vertical_input == 0) {
        // Idle
        image_speed = 0;
        image_index = 0;
    } else {
        // Walking
        image_speed = 1;

        // Choose sprite based on movement direction
        if (_horizontal_input != 0) {
            if (_horizontal_input > 0) {
                sprite_index = rsprite;
            } else {
                sprite_index = lsprite;
            }
        } else {
            if (_vertical_input > 0) {
                sprite_index = dsprite;
            } else {
                sprite_index = usprite;
            }
        }
    }
}