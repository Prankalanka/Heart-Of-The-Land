function InAirState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) : EntityState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) constructor {
	static name = "InAir";
	static num = SH.INAIR;
	static stateSEnter = sEnter;
	grav = _data[0];
	coyoteMax = _data[1];
	yVelMax = _data[2];
	coyoteDistMax = _data[3];
	coyoteBuffer = 0;
	coyoteDist = 0;
	isOverMaxDist = false;
	
	static sEnter = function(_data) {		
		// yVel only becomes 0 if we've been grounded, and then transitioned to the inAir state
		// that's when we want to max out coyote
		if persistVar.yVel == 0 {
			coyoteBuffer = coyoteMax;
		}
		else {
			coyoteBuffer = 0;
		}
	}
	
	static sExit = function() {
		isOverMaxDist = false;
		coyoteDist = 0;
	}
	
	static updLogic = function() {
		if !isOverMaxDist {
			if coyoteDist < coyoteDistMax {
				coyoteDist += abs(persistVar.xVel);
			}
			else {
				isOverMaxDist = true
			}
		}
		
		// Update yVel
		updGrav(getGravMulti() * grav, 1, yVelMax);
			
		// Update coyote buffer
		updCoyote();
	}
	
	static getAnimUpd = function() {
		var _spriteIndex = undefined;
		var _imageIndex = undefined;
		
		// Change anim if we change direction
		_spriteIndex = activeAnims[faceDir(inputHandler.xInputDir)];
		
		// Change anim if we we ascend or descend
		if(sign(persistVar.yVel) == -1) {
			_imageIndex = 1;
		}
		else {
			_imageIndex = 2;
		}
		
		return [_spriteIndex, _imageIndex, undefined];
	}
	
	static checkIdleWalk2 = function() {
		if persistVar.isBelow {
			if inputHandler.xInputDir == 0 and persistVar.xVel == 0 {
				stateMachine.requestChange(SH.IDLE, 2);
			} else {
				stateMachine.requestChange(SH.WALK, 2);
			}
		}
	}
	
	static checkJump2 = function() {
		if  !persistVar.isAbove and inputHandler.jumpInput and coyoteBuffer != 0 and inputHandler.spaceReleasedSinceJump and coyoteDist < coyoteDistMax {
			show_debug_message([coyoteDist]);
			stateMachine.requestChange(SH.JUMP, 2);
		}
	}
		
	static checkClimb2 = function() {
		if inputHandler.climbHeld and inputHandler.surface != undefined and inputHandler.cdClimb == 0 {
			// Check if our x value is closer to the left or right bbox boundary
			var _rightDiff = abs(inputHandler.surface.bbox_right) - abs(persistVar.x);
			var _leftDiff = abs(inputHandler.surface.bbox_left) - abs(persistVar.x);
			var _wallDir = ( abs(_rightDiff) > abs(_leftDiff))? -1 : 1;
			
			stateMachine.requestChange(SH.CLIMB, 2, [_wallDir]);
		}
	}
	
	static checkDash2 = function() {
		// Changes to Dash State if there's input
		if inputHandler.dashInputDir != 0 {
			stateMachine.requestChange(SH.DASH, 2);
		}
	}
	
	checkChanges = function() {
		checkIdleWalk2();
		checkJump2();
		checkClimb2();
	}

	/// Decrements the coyote buffer if it is not 0.
	updCoyote = function() {
		// The coyote buffer is set to a max value every time we're grounded
	    // but decremented every frame we're in the air, until it reaches 0
	    if coyoteBuffer > 0 {
	        // Decrement it
	        coyoteBuffer--;
	    }
	}
	
	getGravMulti = function() {
		var _yVel = persistVar.yVel;
		// Fall faster when you aren't continuing a jump but you're still going upwards (variable/min jump height) 
		if (inputHandler.currJumpFrame == 0 or inputHandler.currJumpFrame == 31) and sign(_yVel) == -1{
			return  2;
		}
		// The only other case is _yInputDir being 1 whilst you're going down or continuing a jump, 
		// (not starting one, cuz that's handled by the jump state) but else is more optimal
		else if _yVel < yVelMax {
			if sign(_yVel) == -1 {
				return 1;
			}
			else {
				return 1.1;
			}
		}
		else {
			return 1;
		}
	}
}