switch camMan {
	case CAM_MANS.PLYR {
	}
} 

camX = lerp(camera_get_view_x(view_camera[0]), targetX, 0.075);
camY = lerp(camera_get_view_y(view_camera[0]), targetY, 0.15);

camera_set_view_pos(view_camera[0], camX, camY);