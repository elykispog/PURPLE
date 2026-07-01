function scr_game_data() 
{
function save_game() {
    // Open or create a file named save.ini
    ini_open("save.ini");
    
    // Write current data (Section, Key, Value)
    ini_write_string("Progress", "Room", room_get_name(room));
    ini_write_real("Player", "X", obj_player.x);
    ini_write_real("Player", "Y", obj_player.y);
    ini_write_real("Player", "HP", global.hp);
	ini_write_real("Player", "LV", global.love);
	ini_write_real("Player", "EXP", global.exp);
	ini_write_real("Player", "AT", global.at);
	ini_write_real("Player", "DF", global.df);
	ini_write_real("Player", "GOLD", global.gold);
	ini_write_real("Player", "KILLS", global.kills);
	ini_write_real("Player", "WEAPON", global.weapon);
	ini_write_real("Player", "ARMOR", global.armor);
    
    // Always close the file to save changes to disk
    ini_close();
}

function load_game() {
    if (file_exists("save.ini")) {
        ini_open("save.ini");
        
        // Read data. Provide default values if data doesn't exist.
        var target_room_name = ini_read_string("Progress", "Room", room_get_name(rm_start));
        var target_x = ini_read_real("Player", "X", 0);
        var target_y = ini_read_real("Player", "Y", 0);
        global.hp = ini_read_real("Player", "HP", 20);
		global.lv = ini_read_real("Player", "LV", 0);
		global.exp = ini_read_real("Player", "EXP", 0);
		global.at = ini_read_real("Player", "AT", 0);
		global.df = ini_read_real("Player", "DF", 0);
		global.gold = ini_read_real("Player", "GOLD", 0);
		global.kills = ini_read_real("Player", "KILLS", 0);
		global.weapon = ini_read_real("Player", "WEAPON", 0);
		global.armor = ini_read_real("Player", "ARMOR", 0);
        
        ini_close();
        
        // Convert the room name string back to an actual room index asset
        var target_room = asset_get_index(target_room_name);
        
        // Transport the player
        room_goto(target_room);
        
        // Position the player (Ensure player exists or spawn them)
        if (instance_exists(obj_player)) {
            obj_player.x = target_x;
            obj_player.y = target_y;
        }
    }
}
}