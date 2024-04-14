// Holds common entity movement functions.

/// @function                updPosVars()
/// @description             Updates isBelow and isAbove value for entity object.
function updPosVars() {
	isBelow = place_meeting(x, (y + 1), colliderArray);
	isAbove = place_meeting(x, (y - 1), colliderArray);
	
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
function updX() {
	var _xStep = sign(xVel);
	var _initX = x;
	var _decimals = xVel -  (_xStep * floor(abs(xVel)));
	var _tempXVel = xVel;
	
	// If we collide, we reset the yVel to 0 to prevent us from still building speed
	// We also set _decimals to 0, so we're the next pixel over from what we're colliding with (no subpixels)
	if (_xStep != 0) and place_meeting(x + xVel, y, colliderArray) {
		_tempXVel = 0; // If we're bumping into something we won't constantly build speed (that could be an interesting game mechanic)
		_decimals = 0;
	} 
	
	// Increment x by integer (pixel) values until we detect an object at the next pixel
	while abs(xVel) >= 1 and !place_meeting(x + _xStep, y, colliderArray) and abs(x - _initX) < abs(xVel - 1 * _xStep) {
		x += _xStep;
	}
	
	x += _decimals; // If we don't do this we can't use sub-pixel movements which throws off our calculations a lot
	xVel = _tempXVel;

	updPosVars();
}
	
	
///@function                updY()
///@description           Updates y value by y velocity and handles collision for the update.								                                                                  Not to be used for swing collisions yet
function updY() {
	var _yStep = sign(yVel);
	var _initY = y;
	var _decimals = yVel - (_yStep * floor(abs(yVel)));
	var _tempYVel = yVel;
	
	if (_yStep != 0 and place_meeting(x, y + yVel, colliderArray)) {
		_tempYVel = 0;
		_decimals = 0;
	}
	
	while abs(yVel) >= 1 and !place_meeting(x, y + _yStep, colliderArray) and abs(y - _initY) < abs(yVel - 1 * _yStep){
		y += _yStep;
	}
	
	y += _decimals;
	yVel = _tempYVel;
	
	updPosVars();
}


///@function                checkStuck()
///@description           Checks if we're stuck then casts a reverse ray out to make sure we get unstuck the shortest distance out.
function checkStuck() {
	// Calculated after we change the sprite because that can slightly change our collision mask
	// If we're inside a platform we move out of it in the way that moves us the least
	// (not a perfect solution, but has worked for everything so far)
	if place_meeting(x, y, colliderArray) {
		var _pXLength = 1;
		var _nXLength = 1;

		var _pYLength = 1;
		var _nYLength = 1;

		// Cast a ray that only continues whilst inside the object
		while (place_meeting(x + _pXLength, y, colliderArray)) {
			_pXLength += 1;
		}
		while (place_meeting(x - _nXLength, y, colliderArray)) {
			_nXLength += 1;
		}
		while (place_meeting(x, y + _pYLength, colliderArray)) {
			_pYLength += 1;
		}
		while (place_meeting(x, y - _nYLength, colliderArray)) {
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


/// Take the direction we want to face in and turn it into an index for our entity's anim array
function faceDir(_velOrDir) {
	switch (_velOrDir) {
	    case 1:
	        dirFacing = 0;
			return 0;
	        break;
	    case -1:
	        dirFacing = 1;
			return 1;
	        break;
		case 0:
			return dirFacing;
			break;
	}
}