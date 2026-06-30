// 1. Get input
var _horizontal_input = keyboard_check(vk_right) - keyboard_check(vk_left);
var _vertical_input = keyboard_check(vk_down) - keyboard_check(vk_up);

// 2. Define your speeds
var _spd = 3;
var _hsp = _horizontal_input * _spd;
var _vsp = _vertical_input * _spd;
move_and_collide(_hsp, _vsp, obj_invisiblewall);


// 3. Animation and Sprite Management
if (_horizontal_input == 0 && _vertical_input == 0) 
{
    // Idle state: Stop animating and freeze on the first frame
    image_speed = 0;
    image_index = 0;
} 
else 
{
    // Walking state: Start animating
    image_speed = 1;
    
    // Change sprite based on the direction of movement
    if (_horizontal_input != 0) {
    
        if (_horizontal_input > 0) sprite_index = rsprite;
        else sprite_index = lsprite;
    } 
    else 
    {
        if (_vertical_input > 0) sprite_index = dsprite;
        else sprite_index = usprite;
    }
}