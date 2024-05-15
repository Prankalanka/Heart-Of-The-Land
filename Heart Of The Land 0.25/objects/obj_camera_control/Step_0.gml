var _prevXCam = xCam;
var _prevYCam = yCam;
var _prevXVel = xVel;
var _prevYVel = yVel;

var _plyrX = 0;
var _plyrY = 0;
var _plyrXInputDir = 0;

switch camMan {
	case CAM_MANS.PLYR:
		var _plyrData = obj_player.getNextCamPos();
		targetX = _plyrData[0];
		targetY = _plyrData[1];
		_plyrX = _plyrData[2];
		_plyrY = _plyrData[3];
		_plyrXInputDir = _plyrData[4];
		
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
targetX += obj_player.persistVar.xVel * lAAccel; // Look ahead of velocity as well (multiplied by that because I randomly found out it works)

xCam = smoothDamp(xCam, targetX, xVel, 8);
yCam = smoothDamp(yCam, targetY, yVel, 1, xVelMax);

camera_set_view_pos(view_camera[0], xCam, yCam);

show_debug_message([lookAheadDist, _plyrXInputDir, lAAccel]);

xVel = xCam - _prevXCam;
yVel = yCam - _prevYCam;