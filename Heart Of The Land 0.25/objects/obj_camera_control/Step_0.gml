var _prevXCam = xCam;
var _prevYCam = yCam;
var _prevXVel = xVel;
var _prevYVel = yVel;

var _xSmoothTime = 0;
var _ySmoothTime = 0;

var _bounds = [0,0,0,0];

switch camMan {
	case CAM_MANS.PLYR:
		var _plyrData = obj_player.getNextCamTarget();
		targetX = _plyrData[0];
		targetY = _plyrData[1];
		_bounds = _plyrData[2];
		_xSmoothTime = _plyrData[3];
		_ySmoothTime = _plyrData[4];
		break
}

// So that we don't have no bounds at all
if _bounds != noone {
	bounds = _bounds;
}

// Clamp target so that we smooth the snapping
targetX = clamp(targetX, bounds[0], bounds[2] - xMidOffset*2);
targetY = clamp(targetY, bounds[1], bounds[3] - yMidOffset*2);

var _xData = smoothDamp(xCam, targetX, xVel, _xSmoothTime); 
var _yData = smoothDamp(yCam, targetY, yVel, _ySmoothTime);

xCam = _xData[0];
xVel = _xData[1];

yCam = _yData[0];
yVel = _yData[1];

camera_set_view_pos(view_camera[0], xCam, yCam);

//show_debug_message([lookAheadDist, _plyrXInputDir, lAAccel]);
//show_debug_message([_ySmoothTime]);
//show_debug_message([_plyrY, yCam, _plyrY - yCam, camera_get_view_height(view_camera[0])/1.3]);