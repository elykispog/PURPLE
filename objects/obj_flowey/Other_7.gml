/// @DnDAction : YoYo Games.Common.Execute_Code
/// @DnDVersion : 1
/// @DnDHash : 0A69FD84
/// @DnDArgument : "code" "image_speed = 0;$(13_10)image_index = image_number - 1; // Stops on the final frame$(13_10)global.lookdown = true;$(13_10)$(13_10)if animation_end = false{$(13_10)	animation_end = true;$(13_10)audio_play_sound(snd_floweytheme, 0, 1, 1.0, undefined, 1.0);$(13_10)alarm[0] = 60;}"
image_speed = 0;
image_index = image_number - 1; // Stops on the final frame
global.lookdown = true;

if animation_end = false{
	animation_end = true;
audio_play_sound(snd_floweytheme, 0, 1, 1.0, undefined, 1.0);
alarm[0] = 60;}