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
		_plyrX = _plyrData[2];
		_plyrY = _plyrData[3];
		_plyrXInputDir = _plyrData[4];
		_plyrXVel = _plyrData[5];
		_ySmoothTime = _plyrData[6];
		
		break
} 

// We stick to the same position if we're not inputting anything
if _plyrXInputDir != 0 {
	// Smoothly transition to next lookAhead value
	var _nextLookAheadDist = (lookAheadDist + lAAccel * _plyrXInputDir) * lADecel;

	// Clamp lookAhead value
	if abs(_nextLookAheadDist) < lookAheadMax {
		lookAheadDist = _nextLookAheadDist;
	}
	else { 
		lookAheadDist = lookAheadMax * _plyrXInputDir;
	}
}

targetX += lookAheadDist;
targetX += _plyrXVel*8// Look ahead of velocity as well (multiplied by that because I randomly found out it works)


xCam = smoothDamp(xCam, targetX, xVel, 8); 
yCam = smoothDamp(yCam, targetY, yVel, _ySmoothTime);


camera_set_view_pos(view_camera[0], xCam, yCam);

//show_debug_message([lookAheadDist, _plyrXInputDir, lAAccel]);
//show_debug_message([_ySmoothTime]);
//show_debug_message([_plyrY, yCam, _plyrY - yCam, camera_get_view_height(view_camera[0])/1.3]);

xVel = xCam - _prevXCam;
yVel = yCam - _prevYCam;