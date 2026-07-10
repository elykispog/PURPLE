// 1. Get input
var _horizontal_input = keyboard_check(global.key_right) - keyboard_check(global.key_left);
var _vertical_input = keyboard_check(global.key_down) - keyboard_check(global.key_up);


// 2. Movement / Interaction
if (!frozen)
{
    if (_vertical_input > 0) facing = Facing.Down;
    if (_vertical_input < 0) facing = Facing.Up;
    if (_horizontal_input > 0) facing = Facing.Right;
    if (_horizontal_input < 0) facing = Facing.Left;

    var interact_x = (bbox_left + bbox_right) * 0.5;
    var interact_y = bbox_bottom;

    switch (facing)
    {
        case Facing.Up:    interact_y -= 20; break;
        case Facing.Down:  interact_y += 8;  break;
        case Facing.Left:  interact_x -= 12; break;
        case Facing.Right: interact_x += 12; break;
    }

    // Find an interactable at that point
    var target = instance_position(interact_x, interact_y, parent_interactable);

    if (target != noone)
    {
        if (keyboard_check_pressed(global.key_confirm))
        {
            target.interact();
            exit;
        }
    }

    // CLIMBING MOVEMENT
    if (climbing)
    {
        var _spd = 1;
        var _hsp = 0;
        var _vsp = _vertical_input * _spd;

        // Only allow vertical movement while facing up/down
        if (facing == Facing.Left || facing == Facing.Right)
        {
            _vsp = 0;
        }

        move_and_collide(_hsp, 0, obj_modularHitbox);
        move_and_collide(0, _vsp, obj_modularHitbox);

        // Animation
        if (_horizontal_input == 0 && _vertical_input == 0)
        {
            image_speed = 0;
            image_index = 0;
        }
        else
        {
            image_speed = 1;

            if (_horizontal_input != 0)
            {
                if (_horizontal_input > 0)
                    sprite_index = rsprite;
                else
                    sprite_index = lsprite;
            }
            else
            {
                if (_vertical_input > 0)
                    sprite_index = dsprite;
                else
                    sprite_index = usprite;
            }
        }
    }
    else
    {
        // NORMAL MOVEMENT
        var _spd = 3;
        var _hsp = _horizontal_input * _spd;
        var _vsp = _vertical_input * _spd;

        move_and_collide(_hsp, 0, obj_modularHitbox);
        move_and_collide(0, _vsp, obj_modularHitbox);

        // Animation
        if (_horizontal_input == 0 && _vertical_input == 0)
        {
            image_speed = 0;
            image_index = 0;
        }
        else
        {
            image_speed = 1;

            if (_horizontal_input != 0)
            {
                if (_horizontal_input > 0)
                    sprite_index = rsprite;
                else
                    sprite_index = lsprite;
            }
            else
            {
                if (_vertical_input > 0)
                    sprite_index = dsprite;
                else
                    sprite_index = usprite;
            }
        }
    }
}

// RIGHT DASH
if (sprite_index == rsprite)
{
    if (keyboard_check_pressed(global.key_confirm))
    {
        var nearest_vine = noone;
        var nearest_dist = 999999;

        for (var i = 0; i < instance_number(obj_vine); i++)
        {
            var vine = instance_find(obj_vine, i);

            // Check vines to the right and anywhere vertically along the vine
            if (vine.bbox_left > x && y >= vine.bbox_top && y <= vine.bbox_bottom)
            {
                var dist = vine.bbox_left - x;

                if (dist < nearest_dist)
                {
                    nearest_dist = dist;
                    nearest_vine = vine;
                }
            }
        }

        if (nearest_vine != noone)
        {
            vine_target_x = nearest_vine.x;
            vine_direction = 1;

            vine_dash = true;
            frozen = true;

            image_index = 0;
            image_speed = 1;
        }
    }
}


// LEFT DASH
if (sprite_index == lsprite)
{
    if (keyboard_check_pressed(global.key_confirm))
    {
        var nearest_vine = noone;
        var nearest_dist = 999999;

        for (var i = 0; i < instance_number(obj_vine); i++)
        {
            var vine = instance_find(obj_vine, i);

            // Check vines to the left and anywhere vertically along the vine
            if (vine.bbox_right < x && y >= vine.bbox_top && y <= vine.bbox_bottom)
            {
                var dist = x - vine.bbox_right;

                if (dist < nearest_dist)
                {
                    nearest_dist = dist;
                    nearest_vine = vine;
                }
            }
        }

        if (nearest_vine != noone)
        {
            vine_target_x = nearest_vine.x;
            vine_direction = -1;

            vine_dash = true;
            frozen = true;

            image_index = 0;
            image_speed = 1;
        }
    }
}


// VINE DASH MOVEMENT
if (vine_dash)
{
    if (x < vine_target_x)
    {
        x = min(x + vine_speed, vine_target_x);
    }
    else if (x > vine_target_x)
    {
        x = max(x - vine_speed, vine_target_x);
    }

    if (x == vine_target_x)
    {
        vine_dash = false;
        frozen = false;

        if (vine_direction == 1)
        {
            sprite_index = rsprite;
        }
        else
        {
            sprite_index = lsprite;
        }

        image_index = 0;
        image_speed = 0;
    }
}