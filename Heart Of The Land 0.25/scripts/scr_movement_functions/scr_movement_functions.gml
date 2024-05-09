// Holds common entity movement functions.

/// @function                updPosVars()
/// @description             Updates isBelow and isAbove value for entity object.
function updPosVars() {
	persistVar.isBelow = place_meeting(x, (y + 1), persistVar.colliderArray);
	persistVar.isAbove = place_meeting(x, (y - 1), persistVar.colliderArray);
	persistVar.x = x;
	persistVar.y = y;
}


/// @function                floorXVel()
/// @description             Floors x velocity value for entity object.
function floorXVel() {
	if 0.05 > abs(persistVar.xVel) {
		persistVar.xVel = 0;
	}
}


/// @function                setXVel()
/// @description             Sets x velocity whilst also flooring it.
function setXVel(_xVel) {
	persistVar.xVel = _xVel;
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
	var _xVel = persistVar.xVel;
	var _xStep = sign(_xVel);
	var _initX = x;
	var _decimals = _xVel -  (_xStep * floor(abs(_xVel)));
	var _tempXVel = _xVel;
	
	// If we collide, we reset the yVel to 0 to prevent us from still building speed
	// We also set _decimals to 0, so we're the next pixel over from what we're colliding with (no subpixels)
	if (_xStep != 0) and place_meeting(x + _xVel, y, persistVar.colliderArray) {
		_tempXVel = 0; // If we're bumping into something we won't constantly build speed (that could be an interesting game mechanic)
		_decimals = 0;
	} 
	
	// Increment x by integer (pixel) values until we detect an object at the next pixel
	while abs(_xVel) >= 1 and !place_meeting(x + _xStep, y, persistVar.colliderArray) and abs(x - _initX) < abs(_xVel - 1 * _xStep) {
		x += _xStep;
	}
	
	x += _decimals; // If we don't do this we can't use sub-pixel movements which throws off our calculations a lot
	persistVar.xVel = _tempXVel;

	updPosVars();
}
	
	
///@function                updY()
///@description           Updates y value by y velocity and handles collision for the update.								                                                                  Not to be used for swing collisions yet
function updY() {
	var _yVel = persistVar.yVel 
	var _yStep = sign(_yVel);
	var _initY = y;
	var _decimals = _yVel - (_yStep * floor(abs(_yVel)));
	var _tempYVel = _yVel;
	
	if (_yStep != 0 and place_meeting(x, y + _yVel, persistVar.colliderArray)) {
		_tempYVel = 0;
		_decimals = 0;
	}
	
	while abs(_yVel) >= 1 and !place_meeting(x, y + _yStep, persistVar.colliderArray) and abs(y - _initY) < abs(_yVel - 1 * _yStep){
		y += _yStep;
	}
	
	y += _decimals;
	persistVar.yVel = _tempYVel;
	
	updPosVars();
}


///@function                checkStuck()
///@description           Checks if we're stuck then casts a reverse ray out to make sure we get unstuck the shortest distance out.
function checkStuck() {
	// Calculated after we change the sprite because that can slightly change our collision mask
	// If we're inside a platform we move out of it in the way that moves us the least
	// (not a perfect solution, but has worked for everything so far)
	if place_meeting(x, y, persistVar.colliderArray) {
		var __pXLength = 1;
		var __nXLength = 1;

		var _pYLength = 1;
		var _nYLength = 1;

		// Cast a ray that only continues whilst inside the object
		while (place_meeting(x + __pXLength, y, persistVar.colliderArray)) {
			__pXLength += 1;
		}
		while (place_meeting(x - __nXLength, y, persistVar.colliderArray)) {
			__nXLength += 1;
		}
		while (place_meeting(x, y + _pYLength, persistVar.colliderArray)) {
			_pYLength += 1;
		}
		while (place_meeting(x, y - _nYLength, persistVar.colliderArray)) {
			_nYLength += 1;
		}

		// Find the smallest rays from the two axes
		var _smolDirX = min(__pXLength, __nXLength);
		var _smolDirY = min(_pYLength, _nYLength);

		// Turn negative if negative value matches the minimum value
		if _smolDirY == _nYLength {
			_smolDirY = _smolDirY * -1;
		} else if _smolDirX == __nXLength {
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
	        persistVar.indexFacing = 0;
			return 0;
	    case -1:
	        persistVar.indexFacing = 1;
			return 1;
		case 0:
			return persistVar.indexFacing;
	}
}

/// @function	checkSetSurface()
/// @description	Looks for an instance in order of distance, touching our extended collision mask in whatever direction. If it has the "climbable" tag and we are facing it, set the value of inputHandle.surface and return true.
 function checkSetSurface(_extBox, _currentSurface = undefined) {
	var _instList = ds_list_create();
	var _listLength = collision_rectangle_list(_extBox[0], _extBox[1], _extBox[2], _extBox[3], all, false, true, _instList, true);
	
	if _listLength != 0 and inputHandler.cdClimb == 0 {
	   for (var i = 0; i < _listLength; i++) {
		   if _instList[|i] != _currentSurface and asset_has_tags(_instList[|i].object_index, "climbable") {
			   // Check if our x value is closer to the left or right bbox boundary
				var _rightDiff = abs( _instList[|i].bbox_right) - abs(persistVar.x);
				var _leftDiff = abs(_instList[|i].bbox_left) - abs(persistVar.x);
				var _wallDir = (abs(_rightDiff) > abs(_leftDiff))? -1 : 1;
			   
			   // Only attach if we're running into the wall
			   //if inputHandler.xInputDir == _wallDir * -1 { // They opposite, if you face right you'll see the left side of the tree
				inputHandler.surface = _instList[|i];
				ds_list_destroy(_instList);
				return true; // breaks out of function, not loop
			   //}
		   }
	   }
	}	
	ds_list_destroy(_instList);
	return false;
} 

/// @function	updGrav()
/// @description	Augments a velocity by a given or default gravity.
function updGrav(_grav, axis, _clamp = 1000000) {
	if axis == 0 {
		// Only augment if the nextXVel is below the clamp
		var _nextXVel = persistVar.xVel - _grav;
		if abs(_clamp) >  abs(_nextXVel) {
			persistVar.xVel = _nextXVel;
		}
		else {
			persistVar.xVel = _clamp;
		}
	}
	else {
		// Only needs to be below the clamp if it's negative
		var _nextYVel = persistVar.yVel - _grav;
		if abs(_clamp) >  abs(_nextYVel) or sign(_nextYVel) == -1 {
			persistVar.yVel = _nextYVel;
		}
		else {
			persistVar.yVel = _clamp;
		}
	}
}