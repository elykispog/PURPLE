// 1. Ensure viewports are enabled
view_enabled = true;
view_visible[0] = true;

// 2. Define Camera Variables
var _cam_width = 960;
var _cam_height = 720;

// 3. Create a new camera if it doesn't exist yet
if (!view_camera[0]) {
    view_camera[0] = camera_create_view(0, 0, _cam_width, _cam_height);
}

// 4. Optionally, assign it as the engine's default camera
camera_set_default(view_camera[0]);

// 5. Set object following (Uncomment below if you want the camera to track your player)
// camera_set_view_target(view_camera[0], obj_player);
// camera_set_view_border(view_camera[0], 200, 200); // Distance before camera moves
