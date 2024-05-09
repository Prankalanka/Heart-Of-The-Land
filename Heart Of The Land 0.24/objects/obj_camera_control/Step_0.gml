var _targetX = 0;
var _targetY = 0;

switch camMan {
	case CAM_MANS.PLYR:
		var _targetPos = obj_player.getNextCamPos();
		_targetX = _targetPos[0];
		_targetY = _targetPos[1];
		break
} 

camX = lerp(camera_get_view_x(view_camera[0]), _targetX, 0.018 + abs(obj_player.persistVar.xVel/300));
camY = lerp(camera_get_view_y(view_camera[0]), _targetY, 0.15);

camera_set_view_pos(view_camera[0], camX, camY);
show_debug_message([(camX + xMidOffset) - obj_player.x]);