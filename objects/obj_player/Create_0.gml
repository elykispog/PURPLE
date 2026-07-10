event_inherited();

image_speed = 0;
image_index = 0;

facing = Facing.Down;
climbing = false;

frozen = false;

// Vine movement
vine_dash = false;
vine_target_x = x;
vine_speed = 20;


// Start climbing
set_climbing = function()
{
    x = obj_vine_climb.x;
    y = obj_vine_climb.y;

    climbing = true;

    vine_dash = false;
    vine_target_x = x;
};


// Change facing direction
set_facing = function(_dir)
{
    facing = _dir;

    switch (_dir)
    {
        case Facing.Up:
            sprite_index = usprite;
            break;

        case Facing.Down:
            sprite_index = dsprite;
            break;

        case Facing.Left:
            sprite_index = lsprite;
            break;

        case Facing.Right:
            sprite_index = rsprite;
            break;
    }

    image_index = 0;
    image_speed = 0;
};


// Freeze player
freeze = function()
{
    frozen = true;
    image_index = 0;
    image_speed = 0;
};


// Unfreeze player
unfreeze = function()
{
    frozen = false;
};


depth = -100;