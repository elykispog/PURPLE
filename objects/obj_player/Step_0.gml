// 1. Get input
var _horizontal_input = keyboard_check(vk_right) - keyboard_check(vk_left);
var _vertical_input   = keyboard_check(vk_down)  - keyboard_check(vk_up);

// Force sprite during cutscenes/look states
if (global.flowey_cutscene1) {
    image_index = 0;
    sprite_index = usprite;
}

if (global.lookdown) {
    image_index = 0;
    sprite_index = dsprite;
}

// 2. Movement
if (!global.cutscene_active) {
    var _spd = 3;
    var _hsp = _horizontal_input * _spd;
    var _vsp = _vertical_input * _spd;

    if ((_dx != 0 && _dy != 0) && place_meeting(x, y, obj_invisiblewall)) {
        var l = point_distance(0, 0, _dx, _dy);
        _hsp = (_dx / l) * _spd;
        _vsp = (_dy / l) * _spd;
    }

    move_and_collide(_hsp, _vsp, obj_invisiblewall);

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

