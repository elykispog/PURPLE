// 1. Gather your input
var _horizontal_input = keyboard_check(vk_right) - keyboard_check(vk_left);
var _vertical_input = keyboard_check(vk_down) - keyboard_check(vk_up);

// 2. Define your speeds
var _spd = 3;
var _hsp = _horizontal_input * _spd;
var _vsp = _vertical_input * _spd;

// 3. Move and collide with your wall object (e.g., obj_wall)
// This will slide the player along the wall instead of letting them pass through or get entirely stuck.
move_and_collide(_hsp, _vsp, obj_invisiblewall);