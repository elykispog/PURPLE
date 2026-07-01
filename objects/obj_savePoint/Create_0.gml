event_inherited();

dialogue = {
	pages: [
		"* Strangely...",
		"* The smell of invisible ink fills you with perseverance.",
	],
	
	on_end: function() {
		instance_create_layer(0, 0, "Text", obj_savebox, { saveLocation: "Ruins" });
	}
}

hitbox = instance_create_layer(x, y, "Instances", obj_modularHitbox, { owner: id });