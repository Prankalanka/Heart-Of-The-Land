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
	var _initX = x;
	// If we're going somewhere and that space is already occupied
	// Go as far as we can 
	if (_xStep != 0) and place_meeting(x + xVel, y, obj_platform) {
		xVel = 0; // If we're bumping into something we won't constantly build speed (that could be an interesting game mechanic)
	} 
	while !place_meeting(x + _xStep, y, obj_platform) and  abs(x - _initX) < abs(xVel){
		x += _xStep;
	}
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
	var _initY = y;
	
	while !place_meeting(x, y + _yStep, obj_platform) and abs(y - _initY) < abs(yVel) {
		y += _yStep;
	}
	
	if (_yStep != 0 and place_meeting(x, y + yVel, obj_platform)) {
		yVel = 0;
	}
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


/// Take the direction we want to face in and turn it into an index for our entity's anim array
function facingDirection(_velOrDir) {
	switch (_velOrDir) {
	    case 1:
	        lastDirFaced = 0;
			return 0;
	        break;
	    case -1:
	        lastDirFaced = 1;
			return 1;
	        break;
		case 0:
			return lastDirFaced;
			break;
		case 2: 
			// Last dir is 0 for compatibility with other states
			// but we can still have multiple animations for specific states
			lastDirFaced = 0;
			return 2;
			break;
		case -2: 
			lastDirFaced = 1;
			return 3;
			break;
	}
}