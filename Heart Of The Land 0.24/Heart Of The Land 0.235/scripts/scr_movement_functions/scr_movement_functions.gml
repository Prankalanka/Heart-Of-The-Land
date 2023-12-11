// Holds common entity movement functions.

/// @function                updPosVars()
/// @description             Updates isBelow and isAbove value for entity object.
function updPosVars() {
	isBelow = place_meeting(x, (y + 1), obj_platform);
	isAbove = place_meeting(x, (y - 1), obj_platform);
	
}


/// @function                floorXVel()
/// @description             Floors x velocity value for entity object.
function floorXVel() {
	if 0.05 > abs(xVel) {
		xVel = 0;
	}
}


/// @function                setXVel()
/// @description             Sets x velocity whilst also flooring it.
function setXVel(_xVel) {
	xVel = _xVel;
	floorXVel();
}


/// @function                setYVel()
/// @description             Just sets y velocity, might add something more later.
function setYVel(_yVel) {
	yVel = _yVel; 
}


///@function                updX()
///@description             Updates x value by x velocity and handles collision for the update.								                                                            Not to be used for swing collisions yet.
function updX(_velOrDir) {
	var _xStep = sign(xVel);
	// If we're going somewhere and that space is already occupied
	// Go as far as we can 
	if (_xStep != 0) and place_meeting(x + xVel, y, obj_platform) {
		while !place_meeting(x + _xStep, y, obj_platform) {
			x += _xStep;
		}
		xVel = 0; // If we're bumping into something we won't constantly build speed (that could be an interesting game mechanic)
	} 
	x += xVel;
	updPosVars();
	// THIS IS WHERE WE CHANGE ANIMATION
	sprite_index = prioStateAnims[facingDirection(_velOrDir)];
	//show_debug_message(facingDirection(_velOrDir));
	checkStuck();
}
	
	
///@function                updY()
///@description           Updates y value by y velocity and handles collision for the update.								                                                                  Not to be used for swing collisions yet
function updY() {
	var _yStep = sign(yVel);
	if (_yStep != 0 and place_meeting(x, y + yVel, obj_platform)) {
		while (!place_meeting(x, y + _yStep, obj_platform)) {
			y += _yStep;
		}
		yVel = 0;
	}
	y += yVel;
	updPosVars();
}


///@function                checkStuck()
///@description           Checks if we're stuck then casts a reverse ray out to make sure we get unstuck the shortest distance out.
function checkStuck() {
	// Calculated after we change the sprite because that can slightly change our collision mask
	// If we're inside a platform we move out of it in the way that moves us the least
	// (not a perfect solution, but has worked for everything so far)
	if place_meeting(x, y, obj_platform) {
		var _pXLength = 1;
		var _nXLength = 1;

		var _pYLength = 1;
		var _nYLength = 1;

		// Cast a ray that only continues whilst inside the object
		while (place_meeting(x + _pXLength, y, obj_platform)) {
			_pXLength += 1;
		}
		while (place_meeting(x - _nXLength, y, obj_platform)) {
			_nXLength += 1;
		}
		while (place_meeting(x, y + _pYLength, obj_platform)) {
			_pYLength += 1;
		}
		while (place_meeting(x, y - _nYLength, obj_platform)) {
			_nYLength += 1;
		}

		// Find the smallest rays from the two axes
		var _smolDirX = min(_pXLength, _nXLength);
		var _smolDirY = min(_pYLength, _nYLength);

		// Turn negative if negative value matches the minimum value
		if _smolDirY == _nYLength {
			_smolDirY = _smolDirY * -1;
		} else if _smolDirX == _nXLength {
			_smolDirX = _smolDirX * -1;
		}

		// Update either x or y depending on which has the smallest ray
		if abs(_smolDirX) < abs(_smolDirY) {
			x += _smolDirX;
			show_debug_message(_smolDirX);
		} else {
			y += _smolDirY;
			show_debug_message(_smolDirY);
		}
	}
	updPosVars();
}


///@function                setSpeedOverTime()
///@description           Used whenever we want to move the player without their input 
function setDistanceOverTime(_endSpeed, _framesToPeak, _axis) {
	//  Alternatively this could be what fully decides our x velocity, 
	// for the y axis it's much less useful to think in terms of velocity
	// This is good for walking and deciding lerp and dashing
	// Hold on, actually maybe not
	
	setDistFrame += 1
	var _decel = (2 * _endSpeed) / sqr(_framesToPeak);
	
	if setSpeedFrame == 1 {
		var _initAccel =  (2 * _endSpeed) / _framesToPeak;
		accel = _initAccel;
	}
	
	accel -= _decel;
	
	if _axis == 0 {
		xVel += accel;	
	}
	else if _axis == 1{
		yVel += accel; 
	}
}