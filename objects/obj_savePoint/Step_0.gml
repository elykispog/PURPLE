// Inside obj_save_point -> Step Event
var player_nearby = place_meeting(x, y, obj_player);

if (player_nearby && keyboard_check_pressed(ord("E"))) {
    // Call our save function
    save_game();
    
    // Visual or audio feedback for the player
    show_debug_message("Game Saved!");
}e