/// @DnDAction : YoYo Games.Common.Execute_Code
/// @DnDVersion : 1
/// @DnDHash : 0A69FD84
/// @DnDArgument : "code" "image_speed = 0;$(13_10)image_index = image_number - 1; // Stops on the final frame$(13_10)global.lookdown = true;"
image_speed = 0;
image_index = image_number - 1; // Stops on the final frame
global.lookdown = true;

/// @DnDAction : YoYo Games.Audio.If_Audio_Playing
/// @DnDVersion : 1
/// @DnDHash : 7A68BB78
/// @DnDArgument : "soundid" "snd_flowey_intro"
/// @DnDArgument : "not" "1"
/// @DnDSaveInfo : "soundid" "snd_flowey_intro"
var l7A68BB78_0 = snd_flowey_intro;if (!audio_is_playing(l7A68BB78_0)){	/// @DnDAction : YoYo Games.Audio.Play_Audio
	/// @DnDVersion : 1.1
	/// @DnDHash : 58865DFD
	/// @DnDParent : 7A68BB78
	/// @DnDArgument : "soundid" "snd_flowey_intro"
	/// @DnDArgument : "loop" "1"
	/// @DnDSaveInfo : "soundid" "snd_flowey_intro"
	audio_play_sound(snd_flowey_intro, 0, 1, 1.0, undefined, 1.0);}