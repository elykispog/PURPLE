image_speed = 0;
image_index = image_number - 1;

if (!animation_end) {
	animation_end = true;
	audio_play_sound(snd_floweytheme, 0, 1, 1.0, undefined, 1.0);
	alarm[0] = 60;
}