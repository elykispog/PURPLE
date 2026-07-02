// Update the persistent player's position to the target coordinates
other.x = target_x;
other.y = target_y;

// Send the player to the target room
room_goto(target_room);