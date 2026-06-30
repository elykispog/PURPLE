/// @DnDAction : YoYo Games.Common.Execute_Code
/// @DnDVersion : 1
/// @DnDHash : 39F2FCB4
/// @DnDArgument : "code" "if (cutscene_started)$(13_10){$(13_10)    cutscene_started = false;$(13_10)}"
if (cutscene_started)
{
    cutscene_started = false;
}

/// @DnDAction : YoYo Games.Movement.Set_Direction_Fixed
/// @DnDVersion : 1.1
/// @DnDHash : 7F6CBD31
/// @DnDArgument : "direction" "270"
direction = 270;

/// @DnDAction : YoYo Games.Movement.Set_Speed
/// @DnDVersion : 1
/// @DnDHash : 6966D089
speed = 0;