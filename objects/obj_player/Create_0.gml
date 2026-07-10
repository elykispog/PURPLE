event_inherited();

image_speed = 0;
facing = Facing.Down;
climbing = false;
climbing = function(){
x = obj_vine_climb.x
y = obj_vine_climb.y
climbing = true;
}
set_facing = function(_dir) {
	facing = _dir;
	
	switch (_dir) {
		case Facing.Up:
		{
			sprite_index = usprite;
			image_index = 0;

			image_speed = 0;
			
			break;
		}
		case Facing.Down:
		{
			sprite_index = dsprite;
			image_index = 0;

			image_speed = 0;
			
			break;
		}
		case Facing.Left:
		{
			sprite_index = lsprite;
			image_index = 0;

			image_speed = 0;
			
			break;
		}
		case Facing.Right:
		{
			sprite_index = rsprite;
			image_index = 0;

			image_speed = 0;
			
			break;
		}
	}
}

frozen = false;

freeze = function() {
	frozen = true;
	image_index = 0;
	image_speed = 0;
}

unfreeze = function() {
	frozen = false;
}

depth = -100;