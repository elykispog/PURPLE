if(keyboard_check_pressed(ord("Z"))){

	if(page+1 < array_length(text)){
	page += 1;
	charCount = 0;
	global.cutscene_active = false;
} else { instance_destroy();
	creator.alarm[1] = 1;
}
}

if(keyboard_check_pressed(ord("X"))){
	charCount = 300
}