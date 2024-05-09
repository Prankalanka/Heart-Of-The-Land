var _targetX = 0;
var _targetY = 0;

switch camMan {
	case CAM_MANS.PLYR:
		var _targetPos = obj_player.getNextCamPos();
		_targetX = _targetPos[0];
		_targetY = _targetPos[1];
		break
} 

var _nextXCam = lerp(camera_get_view_x(view_camera[0]), _targetX, 0.025 + abs(obj_player.persistVar.xVel/275));
var _nextYCam = lerp(camera_get_view_y(view_camera[0]), _targetY, 0.15);

var _xCamPlyrDiff = abs(abs((_nextXCam + xMidOffset)) - abs(obj_player.x));


xCam = _nextXCam;
yCam = _nextYCam;

camera_set_view_pos(view_camera[0], xCam, yCam);

_xCamPlyrDiff = (xCam + xMidOffset) - obj_player.x;
show_debug_message(_xCamPlyrDiff);