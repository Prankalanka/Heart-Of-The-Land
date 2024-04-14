/// Super class for all grounded states.
function GroundedState(_entity, _anims, _data = undefined) : EntityState(_entity, _anims, _data = undefined) constructor {
	xInputDir = 0;
	
	/// You don't keep acceleration when you collide with an object 
	static groundedSEnter = function(_data = undefined) {
		yVel = 0;
	}
	
	/// Update xInput
	static groundedUpdLogic = function() {
		xInputDir = inputHandler.xInputDir;
	}
	
	/// Check region 1 state changes
	static checkGrounded1 =  function() { // Turn changes into functions
		if entity.autonomous {
			// Changes to Dash State if there's input
			if inputHandler.dashInput != 0 {
				stateMachine.requestChange(entity.dashState, 1);
			}
			if (entity.inAirState.inRegion[2] or entity.wallJumpState.inRegion[2]) and inputHandler.climbHeld and entity.checkSurface() {
				// Check if our x value is closer to the left or right bbox boundary
				var _rightDiff = abs(inputHandler.surface.bbox_right) - abs(entity.x);
				var _leftDiff = abs(inputHandler.surface.bbox_left) - abs(entity.x);
				var _wallDir = ( abs(_rightDiff) > abs(_leftDiff))? -1 : 1;
			
				stateMachine.requestChange(entity.climbState, 1, [_wallDir]);
			}
		}
	}
	
	/// Check region 2 changes
	static checkGrounded2 =  function() { // Turn changes into functions
		entity.yVel = 0; // So InAir knows we've been grounded, also perfomance
		if entity.autonomous {
			// Changes to InAir state if nothing is below us
			if  !(entity.isBelow) {
				stateMachine.requestChange(entity.inAirState, 2);
			} // Changes to Jump State if there's input
			else if inputHandler.jumpInput and !entity.isAbove {
				stateMachine.requestChange(entity.jumpState, 2);
			}
			// Changes to Dash State if there's input
			if inputHandler.dashInput != 0 {
				stateMachine.requestChange(entity.dashState, 2);
			}
		}
	}
	
}

/// Changes to move state if xInput
function IdleState(_entity, _anims, _data = undefined) : GroundedState(_entity, _anims, _data = undefined) constructor {
	static name = "Idle";
	static num = STATEHIERARCHY.idle;
	
	static updLogic = function() {
		if entity.autonomous {
			groundedUpdLogic();  // Update xInput
		}
	}
	
	static updAnim = function() {
		if entity.autonomous {
			with entity {sprite_index = idleState.activeAnims[faceDir(inputHandler.xInputDir)];}
		}
	}
	
	static checkWalk1 = function() {
		if entity.autonomous {
			// Go to move state if input
			if xInputDir != 0 or entity.xVel != 0 {
				stateMachine.requestChange(entity.walkState, 1);
			}
		}
	}
	
	static checkWalk2 = function() {
		if entity.autonomous {
			// Go to walk state if input
			if xInputDir != 0 or entity.xVel != 0 {
				stateMachine.requestChange(entity.walkState, 2);
			}
		}
	}
	
	checkChanges1 = function() {
		checkWalk1();
	}
	
	checkChanges2 = function() {
		checkWalk2();

	}
	
	checkChanges = function() {
		if inRegion[1] {
			checkChanges1();
			checkGrounded1();
		}
		
		if inRegion[2] {
			checkChanges2();
			checkGrounded2();
		}
	}
	
}

/// Changes to IdleState if no xInput and xVel is 0
function WalkState(_entity, _anims, _data = undefined) : GroundedState(_entity, _anims, _data = undefined) constructor {
	static name = "Walk";
	static num = STATEHIERARCHY.walk;
	walkVel = _data[0];
	fakeMaxSpeed = _data[1];
	walkVarA = _data[2];
	walkVarB = _data[3];
	walkAccel = _data[4];
	decel = _data[5];
	walkAccelDef = _data[6];
	walkAccelMax = _data[7];
	walkVelMax = 25;
	xVelMax =  ((fakeMaxSpeed * power(walkVelMax, walkVarB)) / (power(walkVarA, walkVarB) + power(walkVelMax, walkVarB))) * sign(walkVelMax);
	xVel = undefined;
	walkInputDir = 0;
	walkAnims = [anims[0], anims[1]];
	idleAnims = [anims[2], anims[3]];
	
	static sEnter = function(_data = undefined) {
		groundedSEnter();
		entity.image_index = 0;  // Start at first walk frame
		walkAccel = walkAccelDef;
		convXToWalk();
	}
	
	static sExit = function() {
		entity.image_speed = 1; // Stop scaling based on horizontal speed
	}
	
	static updLogic = function () {
		groundedUpdLogic(); // Update xInput 
		xVel = entity.xVel;
		
		// Only do when grounded (or when we're not calling the update function from a different state)
		if inRegion[1] {
			// Update xVel and X
			if abs(xVel) <= xVelMax {
				updAccel(); 
				updVel();
			}
			else {
				updXVel();
			}
			with entity {updX();}
		}
	}
	
	static updAnim = function() {
		with entity { 
			// Change animation depending on if we're pressing anything and the speed is above a certain threshold
			if inputHandler.xInputDir == 0 and abs(xVel) < 1 {
				walkState.activeAnims = walkState.idleAnims;
			}
			else {
				walkState.activeAnims = walkState.walkAnims;
			}
			
			// Change anim if we change direction
			sprite_index = walkState.activeAnims[faceDir(inputHandler.xInputDir)];
			// Scale anim speed with x speed
			image_speed = 0.5 + 0.5 * (abs(xVel)/walkState.xVelMax);
			
			checkStuck();
		}
	}
		
	/// Go to idle state if no input and no velocity	
	static checkIdle1 = function() {
		if xInputDir == 0 and xVel == 0 {
			stateMachine.requestChange(entity.idleState, 1);
		}
	}	
	/// Go to idle state if no input and no velocity
	static checkIdle2 = function() {
		if xInputDir == 0 and xVel == 0 {
			stateMachine.requestChange(entity.idleState, 2);
		}	
	}
	
	checkChanges1 = function() {
		checkIdle1();
	}
	checkChanges2 = function() {
		checkIdle2();
	}
	
	checkChanges = function() {
		if inRegion[1] {
			// Check for transitions for this region
			checkChanges1();
			
			// Do parent region1 check
			checkGrounded1();
		}
		if inRegion[2] { 
			checkChanges2();
			checkGrounded2();
		} 
		
	}

	/// @function		updAccel()
	/// @description	If an entity starts changing direction or stops inputting one, increase walkAccel to the max and decrease it over the next few frames to its default value. 
	///							If not, set walkAccel to the default value.
	static updAccel = function() {
		walkInputDir = xInputDir;
		
		// If we're inputting a different direction than we're going 
		// Or if we're not inputting a direction
		if xInputDir != sign(walkVel + xInputDir) or xInputDir == 0 {
			walkInputDir = (xInputDir == 0)? sign(walkVel) * -1 : xInputDir; // Make dir the opposite sign of walkVel if inputDir is 0
			if walkAccel == walkAccelDef {
				walkAccel = walkAccelMax;
			}			
			if walkAccel > walkAccelDef {
				walkAccel -= 0.25;
			} 
			else {
				walkAccel = walkAccelDef;
			}
		} 
		else {	
			walkAccel = walkAccelDef;	
		}
	}

	/// @function	updVel()
	/// @description	Manipulates a value, walkVel, maps it out onto a hill function, and then augments the entity's velocity to become that value
	///		
	/// Increases it in the direction of our xInputDir, with a multiplier that ranges depending on a few conditions.
	static updVel = function() {
		var _currWalkVel = walkVel;
		var _nextwalkVel = walkVel + walkAccel * walkInputDir;
		
		// If we're not inputting a direction and we're changing sign, we should go to 0 instead of constantly jittering between values
		if xInputDir == 0 and sign(_nextwalkVel) != sign(walkVel) { // xInputDir cuz we alter walkInputDir from the true value
			_nextwalkVel = 0;
		}
	
		// Limit walkVel from 25 to -25
		if abs(_nextwalkVel) < walkVelMax {
			walkVel = _nextwalkVel;
		} 
		else {
			walkVel = walkVelMax * walkInputDir;
		}
	
		var _nextXVel = ((fakeMaxSpeed * power(walkVel, walkVarB)) / (power(walkVarA, walkVarB) + power(walkVel, walkVarB))) * sign(walkVel);
		// Recalculated 
		var _currXVel = ((fakeMaxSpeed * power(_currWalkVel, walkVarB)) / (power(walkVarA, walkVarB) + power(_currWalkVel, walkVarB))) * sign(_currWalkVel);
		
		// show_debug_message([_currXVel, _nextXVel]);
		
		var _nextXAccel = _nextXVel - _currXVel;
		entity.xVel += _nextXAccel;
	}
	
	
	/// @function	convXToWalk()
	/// @description	Takes our xVel, and if it's within range finds it on our hill function, and makes walkVel equal to its x value.
	static convXToWalk = function() {
		// Assuming a and n are positive
		if abs(entity.xVel) <= xVelMax {
			var _convWalkVel = power((-(power(walkVarA, -walkVarB) * (-fakeMaxSpeed + abs(entity.xVel)))/abs(entity.xVel)), (-1/walkVarB)) * sign(entity.xVel);
			walkVel = (is_nan(_convWalkVel))? 0 : _convWalkVel;
		}
	}
	
	
	/// @function	updXVel()
	/// @description	Temporary function for decelerating above clamp.
	///		
	/// Eventually we'll use projectile state, or something similar.
	static updXVel = function() {
		// Update xVel when above the cap
		if abs(xVel) * decel <= xVelMax {
			if inputHandler.xInputDir == sign(xVel) {
				walkVel = walkVelMax * sign(xVel);
				entity.xVel = xVelMax * sign(xVel);
			}
			else {
				entity.xVel = xVel * decel;
				convXToWalk();
			}
		}
		else {
			entity.xVel = xVel * decel;
		}
	}
}


#region Useless State
/*
function GroundMotionState(_entity, _anims, _data = undefined) : GroundedState(_entity, _anims, _data = undefined) constructor {
	static name = "Ground Motion";
	static num = 6;
	static groundedUpdLogic = updLogic;
	decel = 0.87;
	walkVarA = entity.walkVarA;
	walkVarB = entity.walkVarB;
	fakeMaxSpeed = entity.fakeMaxSpeed;
	
	static updLogic = function() {
		xVel = entity.xVel;
		var _nextXVel =  xVel * decel;
	
		if abs(_nextXVel) >= entity.xVelMax {
			entity.xVel = _nextXVel;
			with entity {updX(sign(xVel));}
		}
		// If we're going below the clamp then switch to walk acceleration
		else {
			groundedUpdLogic(); // Get xInputDir
			
			// Calculate walkVel based on current xVel
			var _nextwalkVel = (round(power(((xVel * power(walkVarA, walkVarB)) / (fakeMaxSpeed - xVel)), (1/walkVarB))));
			
			// If we aren't holding anything, decrease the abs value of walkVel by four, up to 0
			if xInputDir == 0 {
				// Clamp to 0 or do normal equation
				if sign( _nextwalkVel) != _nextwalkVel + 2.5 * sign(xVel) * -1 {
					entity.walkVel = 0;
				}
				else {
					_nextwalkVel = _nextwalkVel + 2.5 * sign(xVel) * -1;
				}
			}
			// If we are holding a different direction thane we're going, decrease abs value of walkVel by 2.5
			else if xInputDir != sign(_nextwalkVel + sign(xVel)) {
				_nextwalkVel = _nextwalkVel + 2.5 * sign(xVel) * -1;
			}
			// Default
			else {
				_nextwalkVel = _nextwalkVel + xInputDir;
			}
			
			// Clamp walkVel
			if abs(_nextwalkVel) < 25 {
				entity.walkVel = _nextwalkVel;
			} 
			else {
				_nextwalkVel = 25 // Or xVel will end up bigger because we use this var in the calculation			
			}
			
			//show_debug_message(["aaaaaaaaaaaaaaa", _nextwalkVel]);
			// Can rely on previous xVel value because we dont want to decelerate to the opposite sign of our starting velocity
			entity.xVel = ((fakeMaxSpeed * power(_nextwalkVel, walkVarB)) / (power(walkVarA, walkVarB) + power(_nextwalkVel, walkVarB))) * sign(xVel);
			entity.walkVel = _nextwalkVel * sign(xVel);
			with entity {updX(sign(xVel));}
			stateMachine.requestChange(entity.walkState, 1);
		}
	}
	checkGrounded1();
}
*/
#endregion