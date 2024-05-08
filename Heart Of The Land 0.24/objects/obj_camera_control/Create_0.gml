targetX = x - camera_get_view_width(view_camera[0]) / 2;
targetY = y - 1000;
targetX = lerp(targetX, mouse_x, 0.4);
targetY = lerp(targetY, mouse_y, 0.4);

