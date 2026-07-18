freeze = function() {};
unfreeze = function() {};
is_frozen = function() { return false; };
set_facing = function(_dir) {};
play_animation = function(_anim) {};

enum Facing {
    Up,
    Down,
    Left,
    Right
}

global.cutscene_system.ensure_actor_cutscene_state(self);