var _prevXCam = xCam;
var _prevYCam = yCam;
var _prevXVel = xVel;
var _prevYVel = yVel;

var _plyrX = 0;
var _plyrY = 0;
var _plyrXInputDir = 0;
var _plyrXVel = 0;
var _ySmoothTime = 0;

switch camMan {
	case CAM_MANS.PLYR:
		var _plyrData = obj_player.getNextCamPos();
		targetX = _plyrData[0];
		targetY = _plyrData[1];

		break
} 

xCam = smoothDamp(xCam, targetX, xVel, 7); 
yCam = smoothDamp(yCam, targetY, yVel, _ySmoothTime);


camera_set_view_pos(view_camera[0], xCam, yCam);

//show_debug_message([lookAheadDist, _plyrXInputDir, lAAccel]);
//show_debug_message([_ySmoothTime]);
//show_debug_message([_plyrY, yCam, _plyrY - yCam, camera_get_view_height(view_camera[0])/1.3]);

xVel = xCam - _prevXCam;
yVel = yCam - _prevYCam;