// 1. Get input
var _horizontal_input = keyboard_check(global.key_right) - keyboard_check(global.key_left);
var _vertical_input = keyboard_check(global.key_down) - keyboard_check(global.key_up);

// Force sprite during cutscenes/look states
if (global.cutscene_active){
	image_index = 0;
	image_speed = 0;
}
if (global.flowey_cutscene1) {
    image_index = 0;
    sprite_index = usprite;
}

if (global.lookdown) {
    image_index = 0;
    sprite_index = dsprite;
}

// 2. Movement/Interaction
if (!global.cutscene_active) {
	if (_vertical_input > 0) facing = Facing.Down;
	if (_vertical_input < 0) facing = Facing.Up;
	if (_horizontal_input > 0) facing = Facing.Right;
	if (_horizontal_input < 0) facing = Facing.Left;
	
	
	var tx = x;
	var ty = y;

	switch (facing) {
		case Facing.Up: ty -= 8; break;
		case Facing.Down: ty += 8; break;
		case Facing.Left: tx -= 8; break;
		case Facing.Right: tx += 8; break;
	}

	// Find an interactable at that point
	var target = instance_position(tx, ty, parent_interactable_text);
	
	if (target != noone) {
		if (keyboard_check_pressed(global.key_confirm)) {
			
			target.interact();
		}
	}
	
    var _spd = 3;
    var _hsp = _horizontal_input * _spd;
    var _vsp = _vertical_input * _spd;
	
    move_and_collide(_hsp, 0, obj_invisiblewall);
	move_and_collide(0, _vsp, obj_invisiblewall);

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

