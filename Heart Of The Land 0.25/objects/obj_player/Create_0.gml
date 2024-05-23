#region Walk State Setup
var _walkAnims = [spr_walk_right, spr_walk_left, spr_idle_right, spr_idle_left];

var _walkVel = 0;
var _fakeMaxSpeed = 12.2;
var _walkVarA = 12;
var _walkVarB = 2;
var _walkAccel = 2.4;
var _decel = 0.94;
var _walkAccelDef = 2.4;
var _walkAccelMax = 4;
var _walkVelMax = 32;
var _walkDeltaAccel = 0.125;

var _walkData = [_walkVel, _fakeMaxSpeed, _walkVarA, _walkVarB, _walkAccel, _decel, _walkAccelDef, _walkAccelMax, _walkVelMax, _walkDeltaAccel];
#endregion

#region Health State Setup (Make a health region eventually)
// Health state or smthn
maxHp = 100;
hp = maxHp;
attack = 50;
attackCd = true;

#endregion

#region Idle State Setup
var _idleAnims =  [spr_idle_right, spr_idle_left];
#endregion

#region Jump / In Air State Setup
var _jumpAnims = [spr_jump_right, spr_jump_left];
var _inAirAnims = [spr_jump_right, spr_jump_left];

// Jump State
var _peak = -300;
var _framesToPeak = 23;
var _initJumpVel = (2 * _peak) / _framesToPeak + _peak/sqr(_framesToPeak);
var _grav = (2 * _peak) / sqr(_framesToPeak); // in Air State also

// In Air State
var _coyoteMax = 90;
var  _yVelMax = 30;
var _coyoteDistMax = 40;

var _inAirData = [_grav, _coyoteMax, _yVelMax, _coyoteDistMax];
var _jumpData = [_peak, _framesToPeak, _initJumpVel, _grav, _yVelMax];
#endregion

#region Dash State Setup
var _dashAnims = [spr_idle_right, spr_idle_left];

var _dashDashDuration = 12;

var _dashData = [_dashDashDuration];
#endregion

#region Air Dash State Setup
var _aDPeak = -100;
var _aDFramesToPeak = 12;
var _aDInitYVel = (2 * _aDPeak) / _aDFramesToPeak + _aDPeak/sqr(_aDFramesToPeak);
var _aDGrav = _grav;
var _aDDashDuration = 12;

var _airDashData = [_aDPeak, _aDFramesToPeak, _aDInitYVel, _aDGrav, _aDDashDuration];
 #endregion
 
#region Swing State Setup
// Only needed inside the swing state except for collision (swing-exclusive collide function? can be done through polymorphism)
swing = undefined;
swingX = 0;
swingY = 0;
swingAngleVelocity = 0;
swingAngle = 0;
swingDistance = 100;

#endregion

#region Climb State Setup
// Climb
var _slideDownVel = 6;
var _slideDownerVel = 10;

var 	_getClimbBox = function(_dirFacing) {
	// Reduce the hitbox in the opposite direction we're facing
	 if _dirFacing = 1 {
		return [bbox_left + sprite_width/8, bbox_top, bbox_right, bbox_bottom];
	}
	else {
		return [bbox_left, bbox_top, bbox_right - sprite_width/8, bbox_bottom];
	}
}

var _checkClimbCont = function() {
	var _inAnyRegion = array_any(states[SH.CLIMB].inRegion, function(_val, _ind)
	{
		return _val == true
	});
	if inputHandler.climbHeld and !_inAnyRegion {
		var _dirFacing = (persistVar.indexFacing == 0)? 1 : -1;
		var _extBox =  [bbox_left, bbox_top, bbox_right, bbox_bottom];
		
		// Reduce the hitbox in the opposite direction we're facing
		if _dirFacing = 1 {
			_extBox = [bbox_left + sprite_width/8, bbox_top, bbox_right, bbox_bottom];
		}
		else {
			_extBox = [bbox_left, bbox_top, bbox_right - sprite_width/8, bbox_bottom];
		}
		
		checkSetSurface(_extBox);
	}
}


var _climbData = [_slideDownVel, _slideDownerVel, _getClimbBox];
#endregion

#region Wall Jump Setup
// Wall Jump
var _xWJPeak = -80;
var _xWJFramesToPeak = 16;
var _xWJInitVel = (2 * _xWJPeak) / _xWJFramesToPeak + _xWJPeak/sqr(_xWJFramesToPeak);
var _xWJGrav = (2 * _xWJPeak) / sqr(_xWJFramesToPeak);

var _yWJPeak = -250;
var _yWJFramesToPeak = 19;
var _yWJInitVel = (2 * _yWJPeak) / _yWJFramesToPeak + _yWJPeak/sqr(_yWJFramesToPeak);
var _yWJGrav = (2 * _yWJPeak) / sqr(_yWJFramesToPeak);

var _wallJumpData = [_xWJInitVel, _xWJFramesToPeak, _xWJPeak, _xWJGrav, _yWJInitVel, _yWJFramesToPeak, _yWJPeak, _yWJGrav];
#endregion

#region Idle Combat Setup 
var _checkSetHeld = function() {
	if place_meeting(x, y, par_throwable) {
		var _held = instance_nearest(x, y, par_throwable);
					
		// Done here so they're at the hold and held states at the same time
		stateMachine.requestChange(holdState, 0, _held);
		_held.stateMachine.requestChange(_held.heldState, 0, id);
		_held.stateMachine.requestChange(_held.heldState, 1, id);
		_held.stateMachine.requestChange(_held.heldState, 2, id);
	}
}

var _idleCombatData = [_checkSetHeld];
#endregion

#region Old Functions

// Could do movement where it takes any, value and iterates on it, but that's better for projectile so this movement should follow a graph like 
// jumping does, how would we get lerp and other things with a pre-determined graph
// Basically we'll accelerate the graph if we're inputting a different direction than we're going, and also really fast when we're not inputting anything

function walkUpd(_xInputDir) {
    // Alter our acceleration  depending on the situation
	if _xInputDir != 0 and abs(xVel) <= xVelMax{
	    // Probably make conditions into vars for more readability
	    if abs(xVel) < 3 {
	        // If we're below an absolute velocity of 3, accelerate slower
	        xDecel = 0.999;
	        xAccel = 0.4;
	    }
	    else if sign(xVel) != _xInputDir and abs(xVel) < xVelMax {
	        // If we're pressing a different direction than we're moving 
	        // If we're actually pointing a way
	        // If we're below the clamp
	        // Deccelerate slower so we have a little slow down and then switch directions
			// This is how i do lerp, fight me.
	        xDecel = 0.999;
	        xAccel = 0.4;
	    }
		else {
		    // Default
		    xDecel = 0.86;
		    xAccel = (xAccel < 2.5) ? xAccel + 0.05 : 2.5;
		}
	}
	else if abs(xVel) <= xVelMax {
		// If we aren't pressing a direction
		// Slow down real fast
		xDecel = 0.83;
		xAccel = 2.5;
    } 
	else {
		// Whenever xVel is above clamp
		xDecel = 0.95;
		xAccel = 0.05;
	}

    // Adds the acceleration based on the direction we're pressing to our previous velocity 
    // The decel variable causes what would have been linear acceleration to get lower over time plateuing at a bit above the value of our clamp
    // This makes movement feel smooth and not like you're hitting a random wall and can't go any faster
    var _nextXVel = (xVel + xAccel * 1.2 * _xInputDir) * xDecel;

    if abs(xVel) > xVelMax {
        // If we're going above the limit and in the same direction as before
        // Don't add anything to the acceleration 
        _nextXVel = xVel * xDecel;
        xVel = _nextXVel;
    } /*else if abs(xVel) > xVelMax and _xInputDir != sign(xVel) {
        // If we're going above the limit and not in the same direction
        // Add acceleration allowing for players to cut their dashes short
        _nextXVel = (xVel + xAccel * 1.2 * _xInputDir) * xDecel;
        xVel = _nextXVel;
    } */ 
	else {
        // Otherwise use the normal acceleration and clamp
        xVel = (abs(_nextXVel) < xVelMax) ? _nextXVel : xVelMax * _xInputDir;
    }
	floorXVel();
}

function swingCheck() {
    // If we're holding w and colliding with the swing object
    // (will change to more of a collision box with you going different directions depending on your direction and position)
    if (keyboard_check(vk_up) or keyboard_check(ord("W"))) and place_meeting(x, y, obj_swing) {
        // If we are below the swing
        if y > obj_swing.y {
            // Define the swing we collided with as our swing and find the angle between it and the player
            swing = obj_swing;
            swingAngle = point_direction(swing.x, swing.y, x, y);
            x = swing.x + lengthdir_x(swingDistance, swingAngle);
            y = swing.y + lengthdir_y(swingDistance, swingAngle);
        }
    }
}

function swingUpd() {
    // Make sure we're holding up or w
    // Declared outside so we can use in scope of above if statement
    var _swingAngleAcceleration = 0;

    // Adjust acceleration based on angle
    // If we're near parallel to gravity
    if (swingAngle < 300 and swingAngle > 240) or(swingAngle < 120 and swingAngle > 60) {
        // Make the multiplier of the acceleration stronger
        // We use dcos function because we are using degrees and also
        // Cosine gives us behaviour where angles that are analagous to up and down in gamemaker
        // return a smaller result, so we'll be slowest when we're directly above or below the swing
        // Emulating real life
        _swingAngleAcceleration = -0.2 * dcos(swingAngle);
    } else {
        _swingAngleAcceleration = -0.2 * dcos(swingAngle);
    }

    // Adjust acceleration based on x and y velocity when on the first swing frame
    if swingAngleVelocity == 0 {
        _swingAngleAcceleration += xVel * 0.325;
        _swingAngleAcceleration += yVel * 0.325;
    }

    swingAngleVelocity += _swingAngleAcceleration;
    swingAngle += swingAngleVelocity;
    swingAngleVelocity *= 0.99 // Dampen velocity, eventually reaching 0

    // Calculate where our next position on the circle should be
    swingX = swing.x + lengthdir_x(swingDistance, swingAngle);
    swingY = swing.y + lengthdir_y(swingDistance, swingAngle);

    // Find the difference between our current position and future position
    // Assign that as the velocity variables so that x and y update functions handle collision
    xVel = swingX - x;
    yVel = swingY - y;

    if !(keyboard_check(vk_up) or keyboard_check(ord("W"))) {
        magnitude = sqrt(sqr(xVel) + sqr(yVel));
        /*
        magnitude = sqrt(sqr(xVel) + sqr(yVel));
        x3 = swing.x - x;
        y3 = swing.y - y;
        m1 = x3/y3;
        m2 = -1(1/m1);
        yDir = sign(yVel);
        c = y - m2 * x;
        x = 
        yVel = m2 * (x + magnitude) + c;
        */

        yVel = magnitude * 2 * sign(yVel);
        xVel = magnitude * 4 * sign(xVel);
        //stateTransition(EntityStates.base);
    }
}

function checkHp() {
    if hp <= 0 {
        obj_destroyer.destroy_obj(id);
    }
}

function attackExec() {
    mouseAngle = point_direction(x, y, mouse_x, mouse_y);

    // Find the vector between the mouse and the player
    mx = mouse_x - x;
    my = mouse_y - y;

    // FInd the magnitude of that vector
    mag = sqrt(sqr(mx) + sqr(my));

    // Normalise that vector and then multiply it by 50
    // This let's us take the direction of the player to the mouse
    // But clamp that distance to 50 pixels
    fx = (mx / mag) * 50;
    fy = (my / mag) * 50;

    // Create an instance of the hit object at a 50 pixel offset from the player
    instance_create_layer(x + fx, y + fy, "Instances", obj_hit, {
        image_angle: mouseAngle - 90, // Rotate the image, not the object
        image_xscale: 0.3,
        image_yscale: 0.3,
        // The object needs the offset values, so we set them here
        fx: fx,
        fy: fy
    });

    // Reset the attack cooldown
    attackCd = false;
    alarm[0] = 30;
}

function moveCamera() {
	

}
#endregion
 
 #region Player Camera Control 
getNextCamTarget = function() {
	// Smooth times
	var _xCamSmoothTime = 7;
	var _yCamSmoothTime = 0.25;
	
	// X Target Setup
	xCamTarget = x - camera_get_view_width(view_camera[0]) / xCamOffset;
	
	// Look ahead
	// We stick to the same position if we're not inputting anything
	if inputHandler.xInputDir != 0 {
		// Smoothly transition to next lookAhead value
		var _nextLookAheadDist = (lookAheadDist + lAAccel * inputHandler.xInputDir) * lADecel;

		// Clamp lookAhead value
		if abs(_nextLookAheadDist) < lookAheadMax {
			lookAheadDist = _nextLookAheadDist;
		}
		else { 
			lookAheadDist = lookAheadMax * inputHandler.xInputDir;
		}
	}

	xCamTarget += lookAheadDist;
	xCamTarget += persistVar.xVel * _xCamSmoothTime; // Look ahead of velocity as well (multiplied by that because I randomly found out it works)
	
	// Y Target Setup
	var _plyrCamPos = y - camera_get_view_height(view_camera[0]) / yCamOffset;
	var _yPlyrCamOffset = y - (camera_get_view_y(view_camera[0]) + yCamMid);
	
	// Clamp to maximum boundary if exceeding it
	if sign(_yPlyrCamOffset) == 1 {
		smoothYVel = lerp(smoothYVel, _yPlyrCamOffset + 40  * _yCamSmoothTime * 1, 0.01);
		var _nextYCamTarget = _plyrCamPos + smoothYVel;
		yCamTarget = lerp(yCamTarget, _nextYCamTarget, 0.3);
	 }
	 // Clamp to maximum boundary if exceeding it
	else if abs(_yPlyrCamOffset) >= yMaxPlyrCamOffset {
			yCamTarget = _plyrCamPos + yMaxPlyrCamOffset * sign(_yPlyrCamOffset) * -1;
	} 
	else {
		smoothYVel = 0;
	}
	 
	if xCamTarget > xBoun
	
	return [xCamTarget, yCamTarget];
}
#endregion

#region Context Setup (Only the context uses these)
// State Machine
activeStates = undefined;
prioState = undefined;

canShowRequests = true;
canShowStates = false;

// Camera
xCamOffset = 2;
yCamOffset = 2;

xCamTarget = x - camera_get_view_width(view_camera[0]) / xCamOffset;
yCamTarget = y - camera_get_view_height(view_camera[0]) / yCamOffset;
 
yCamTargetVel = 0;

xMidOffset = camera_get_view_width(view_camera[0]) / xCamOffset;
yMidOffset = camera_get_view_height(view_camera[0]) / yCamOffset;

xMaxPlyrCamOffset = camera_get_view_width(view_camera[0]) / 6.75;

yCamMid = camera_get_view_height(view_camera[0]) / yCamOffset;
yMaxPlyrCamOffset = camera_get_view_height(view_camera[0]) / 6.75;
smoothYVel = 0;

yCamLerpTarget = 0;

// Debug
xVelArray = [];

initX = x;
initY = y;
#endregion

#region Input Handler Setup (Handles the user and context's inputs for all states)  Maybe eventually should be its own object or constructor)
inputHandler = {
	xInputDir : 0,
	checkWalk : function() {
		xInputDir = 0;
		
		var _left = keyboard_check(vk_left) or keyboard_check(ord("A"));
	    var _right = keyboard_check(vk_right) or keyboard_check(ord("D"));

	     xInputDir = _right - _left;
	},
	
	jumpInput : false, // For now only one variable, but might seperate into multiple vars for more control
	spaceReleasedSinceJump : true,
	jumpBufferMax : 14,
	jumpBuffer : 0,
	jumpFramesToPeak : _framesToPeak,
	currJumpFrame : 0,
	checkJump : function() {
		jumpInput = false;
			// Jump conditions can be temporary variables in the player data script, encapsulated in some way
			// Too much boilerplate get rid of some vars, and rename the ones we already have if  it's not clear enough
			// Only need to update them in here, will send signal to something else and that will check conditions
			// We don't always need to check the conditions but we always need to check the inputs
			// Coyote is not here since it isn't really to do with input, more context 
		if (!keyboard_check(vk_space)) {
				// (VERY IMPORTANT) Only set false when we have done a valid jump
			spaceReleasedSinceJump = true;
		}
		
		if keyboard_check_pressed(vk_space) {
			jumpBuffer = jumpBufferMax;
		} else if jumpBuffer > 0{
			jumpBuffer -= 1;
		}

		// Counts up to 31 when holding space, resets only when space is released since we've succesfully jumped
		// if we haven't done a valid jump since we've released space it doesn't increment
		// meaning it won't increment if we're mid-jump, release space and then try to jump again, there's no air jump yet so jumping mid-air does nothing
		if !spaceReleasedSinceJump and currJumpFrame < jumpFramesToPeak + 1 {
			currJumpFrame++;
		} else if spaceReleasedSinceJump { 
			currJumpFrame = 0;
		}
		
		// Jump Input Conditions
		if (jumpBuffer > 0) {
			jumpInput = true;
		}
	},
	
	dashInputDir : 0, // Ranges from -1 to 1
	groundedAfterAirDash : true,
	checkDash : function() {
		dashInputDir = 0;
		
		if keyboard_check_pressed(vk_shift) {
			dashInputDir = (other.persistVar.indexFacing == 0)? 1 : -1;
		}
		
		if other.persistVar.isBelow {
			groundedAfterAirDash = true;
		}
	},
	
	swingInput : false,
	swingObj : undefined,
	checkSwing : function() {
	    // If we're holding w and colliding with the swing object
	    // (will change to more of a collision box with you going different directions depending on your direction and position)
	    if (keyboard_check(vk_up) or keyboard_check(ord("W"))) and obj_player.place_meeting(obj_player.x, obj_player.y, obj_swing) {
	         swingInput = true;
	    }
	},
	/*  VERY IMPORTANT, RUN THIS IN THE FIRST FRAME OF SWINGING
	    swingAngle = point_direction(swingObj.x, swingObj.y, x, y);
	    x = swingObj.x + lengthdir_x(swingDistance, swingAngle);
	    y = swingObj.y + lengthdir_y(swingDistance, swingAngle);
	*/
	
	holdInput : false,
	throwPos : [0,0],
	holdHeld : false,
	holdCancel : false,
	checkThrow : function() {
		holdInput = false;
		
		// Set hold input and held to true at first frame
		if mouse_check_button_pressed(mb_right) {
			holdInput = true;
			holdHeld = true;
		}
		
		// Keep held true and update throwPos  if we're holding
		holdHeld = mouse_check_button(mb_right);
		if holdHeld {throwPos = [mouse_x, mouse_y];}
		
		// Check if we're trying to cancel (make this put it into our inventory if it can)
		holdCancel = mouse_check_button_pressed(mb_left);
	},
	
	climbHeld : false,
	wallSlideHeld : false,
	surface : undefined,
	cdClimb : 0,
	cdClimbMax : 5,
	checkClimb : function() {
		// Keep true if we're holding
		climbHeld = (keyboard_check(ord("W")) or keyboard_check(vk_up))? true : false;
		wallSlideHeld = (keyboard_check(ord("S")) or keyboard_check(vk_down))? true : false;
		if cdClimb > 0 {
			cdClimb--;
		}
		surface = undefined; // We check for surface after user input checks so this is alright
	},
	
	checkNothing : function() {
	}, 
	
	/// Check every input in the inputFunctions array
	checkUserInputs : function() {	
		var _len = array_length(inputFunctions);
		
		for (var i = 0; i < _len; i++) {
			inputFunctions[i]();
		}
	},
	
	checkContextInputs : function() {
	}
};

inputHandler.inputFunctions = [inputHandler.checkWalk, inputHandler.checkJump, inputHandler.checkDash, inputHandler.checkThrow, inputHandler.checkClimb];
inputHandler.checkClimbCont = _checkClimbCont;
inputHandler.checkContextInputs = function() {
	inputHandler.checkClimbCont();
}
#endregion

#region Persistant Variable Setup (Holds variables that the states need to read/write to, that multiple states need)
persistVar = { 
	// Context
	colliderArray : [obj_platform, obj_block],
	isBelow : false,
	isAbove : false,
	indexFacing : 0,
	
	xVel : 0,
	yVel : 0,
	
	// Walk 
	xVelMax : ((_fakeMaxSpeed * power(_walkVelMax, _walkVarB)) / (power(_walkVarA, _walkVarB) + power(_walkVelMax, _walkVarB))) * sign(_walkVelMax),	
}

#endregion

#region New Entity Functions

#endregion

#region State Machine, State Creation and Initialisation
stateMachine = new EntityStateMachine();

states = [];

/// Takes specific entity data as input, alters the entity's and its own data depending on input.
/// Specifically, they can alter which states are active, leading to major behavioural changes.
states[SH.IDLE] = new IdleState(persistVar, stateMachine, inputHandler, _idleAnims);
states[SH.WALK] = new WalkState(persistVar, stateMachine, inputHandler, _walkAnims, _walkData);
states[SH.INAIR] =  new InAirState(persistVar, stateMachine, inputHandler, _inAirAnims, _inAirData);
states[SH.JUMP] = new JumpState(persistVar, stateMachine, inputHandler, _jumpAnims, _jumpData); 
states[SH.DASH] = new DashState(persistVar, stateMachine, inputHandler, _dashAnims, _dashData); 
states[SH.PROJECTILE] = new ProjectileState(persistVar, stateMachine, inputHandler, _idleAnims);
states[SH.IDLECOMBAT] = new IdleCombatState(persistVar, stateMachine, inputHandler, _idleAnims, _idleCombatData);
states[SH.HOLD] = new HoldState(persistVar, stateMachine, inputHandler, _idleAnims);
states[SH.CLIMB] = new ClimbState(persistVar, stateMachine, inputHandler, _idleAnims, _climbData);
states[SH.WALLJUMP] = new WallJumpState(persistVar, stateMachine, inputHandler, _idleAnims, _wallJumpData);
states[SH.AIRDASH] = new AirDashState(persistVar, stateMachine, inputHandler, _inAirAnims, _airDashData);

#region State Functions
/// In its own function so states don't have to be defined when we create the stateMachine.
/// Sets activeStates to arguments, enters and regions the activeStates, and sets prioState
initStates = function(_startingStates)
{
	activeStates = _startingStates;
		
	// Enter and region all current states
	for (var i = 0; i < array_length(activeStates); i++) {
		activeStates[i].inRegion[i] = true;
		activeStates[i].sEnter();
	}
	
	// Figure out which state in the hierarchy we should have the animation of
	prioState = getPrioState([activeStates[0].num, activeStates[1].num, activeStates[2].num]);
}

/// Checks what changes the current states are requesting, changes the requesting states and possibly the priority state depending on hierarchy. 
/// Does the updLogic for each state, and finally does the getAnimUpd function for the priority state.
execPipeLine = function() {
	if persistVar.isBelow {
		lastGroundedY = y;
	}
	
	inputHandler.checkUserInputs();
	inputHandler.checkContextInputs();
	
	checkChanges();
		
	if canShowRequests {
		stateMachine.showRequests();
	}
		 
	changeStates();
		 
	if canShowStates {
		showStates();
	}
	
	updLogic();
	
	// Update animation once all the context has been decided
	var _animData = prioState.getAnimUpd();
	if _animData != undefined {
		updAnim(_animData[0], _animData[1], _animData[2]);
	}
	
	updPos();
}

// Run updLogic func for each state
updLogic = function() {
	// Resets so we can tell which ones are unique again
	for (var i = 0; i < array_length(activeStates); i++) {
		activeStates[i].updated = false;
	}
		
	// Does the update logic for each unique state once
	for (var i = 0; i < array_length(activeStates); i++) {
		if !activeStates[i].updated {
			activeStates[i].updLogic();
			activeStates[i].updated = true;
		}
	}
}

// Upd x and y based on persistVar's x and y velocities
updPos = function() {
	// Update Position (states only control velocity)
	if persistVar.xVel != 0 {updX();}
	if persistVar.yVel != 0 {updY();}
}

// Set arguments to their respective variables
updAnim = function(_spriteIndex = undefined, _imageIndex = undefined, _imageSpeed = undefined) {
	// GONNA BE FUNC OF ENTITY
	if _spriteIndex != undefined {
		sprite_index = _spriteIndex; // Face correctly
	}
	if _imageIndex != undefined {
		image_index = _imageIndex;
	}
	if _imageSpeed != undefined {
		// Scale anim speed with x speed
		image_speed = _imageSpeed;
	}
	checkStuck();
}

/// If stateChanged is true, for every non-empty region of stateChanges, check which requested state is highest in the hierarchy.
/// Possibly call the enter and exit functions of the requested and requesting states respectively, whilst always changing the inRegion values.
/// After looping through all regions, set the prioState and reset the stateChanged, stateChanges, and changeData variables.
changeStates = function() {
	var _stateChanges = stateMachine.stateChanges
	if stateMachine.stateChanged {
		for (var i = 0; i < array_length(_stateChanges); i++) {
			if array_length(_stateChanges[i]) != 0 {
				// Sort by hierarchy
				var _prioState = getPrioState(_stateChanges[i]);
					
				// If current state isn't a duplistate do the exit function for that state
				if !isDuplistate(activeStates[i]) {
					activeStates[i].sExit();	
				}
					
				// Set current and next state inRegion values
				activeStates[i].inRegion[i] = false;
				activeStates[i] = _prioState;
				activeStates[i].inRegion[i] = true;
					
				// If new state isn't a duplistate do the enter function for that state
				var _changeData = stateMachine.changeData;
				if !isDuplistate(activeStates[i]) {
					if array_length(_changeData) != 0 and _changeData[_prioState.num] != undefined {
						activeStates[i].sEnter(_changeData[_prioState.num]);
					}
					else {
						activeStates[i].sEnter();
					}
					var _animData = activeStates[i].getAnimEnter();
					if _animData != undefined {
						updAnim(_animData[0], _animData[1], _animData[2]);
					}
				}
			}
		}
		
		prioState = getPrioState([activeStates[0].num, activeStates[1].num, activeStates[2].num]);
			
		// Reset
		stateMachine.stateChanged = false;
		stateMachine.stateChanges = [[], [], []];
		stateMachine.changeData = [];
	}
}

// Run checkChanges func for each state
checkChanges = function() {
	// Resets so we can tell which ones are unique again
	for (var i = 0; i < array_length(activeStates); i++) {
		activeStates[i].checked = false;
	}
		
	// Does the doCheck function for each unique state once
	// If we do it per state, they might not have the same context to check from
	for (var i = 0; i < array_length(activeStates); i++) {
		if !activeStates[i].checked {
			activeStates[i].checkChanges();
			activeStates[i].checked = true;
		}
	}
}

/// Check if the input state, is found multiple times in the activeStates array
isDuplistate = function(_state) {
	var _count = 0;
	for (var i = 0; i < array_length(activeStates); i++) {
		if activeStates[i] == _state{
			_count++;
			if _count >= 2 {
				return true;
			}
		}
	}
	return false;
}
	
/// Return which state of activeStates is highest in the hierarchy 
getPrioState = function(_nums) {
	// Figure out which state in the hierarchy we should have the animation of
	return states[script_execute_ext(max, _nums)];
}

/// Display the names of each currentState in the console
showStates = function() {
	var _currentNames = [undefined, undefined, undefined];
	for (var i = 0; i < array_length(activeStates); i++) {
		_currentNames[i] = activeStates[i].name;
	}
	show_debug_message(_currentNames);
}
#endregion

// INITIALISE THE STATE MACHINE
var _startingStates = [states[SH.IDLECOMBAT], states[SH.IDLE], states[SH.IDLE]];
initStates(_startingStates);

// // walkVel testing
//for (var i = 0; i <= 8.94; i += 0.01) {
//	var _convWalkVel = power((-(power(states[SH.walk].walkVarA, -states[SH.walk].walkVarB) * (-states[SH.walk].fakeMaxSpeed + i))/i), (-1/states[SH.walk].walkVarB));
//	array_push(xVelArray, [i, _convWalkVel]);
//}
#endregion

// NEXT STEPS
// Movement feels halfway to alright, but we wanna know how it feels with the full movement system so we're doing that
// Leaving physics alone for a while 
// Might change the names of some functions
//	Adding climb state:
// Get it to release when you're not touching it anymore (if there is another wall in the collision box don't change state, just change the surface to that surface) YAAAAAAAAA
// Get wallDir to depend on which bbox you're closest to, not the last direction you faced YAAAAAAAAAAAAAAAA
// Get an press input variable in addition to the held one we already have NAAAAAAAA it's not as good
// Get an input variable to make sure we facing the wall that we want to climb YAAAAAAAAAAAAAAAAAAA
// Fall at a constant speed YAAAAAAAAAAAAAAAAAAA
// Fall slower for the first few frames of climbing NAAAAAAAAAAAAAAAAAAAA It's worse
// Have a tiny cooldown for previously climbed surfaces (part of wall jumping, less of a buffer for letting go if there even is one) YAAAAAAAAAAAAAAAAAAAAAAAAAAAA
// Get wall jump working YAAAAAAAAAAAAAAAAAA
// Get wall jump to follow a predetermined path if not interfered with using updGrav, if interfered with, switch control of the axis (region) to the other state YAAAAAAAAAAAAAAAAA
// We'll do this on the x axis by converting the walkVel to one that corresponds with the current xVel, inAir doesn't really need to change YAAAAAAAAAAAAAAA
// Get a generalised animation update for each state YAAAAAAAAAAAAAAAAAAAAAA
// Improve the checkStuck function
// GET RID OF THAT AUTONOMOUS BULLSHIT YAAAAAAAAAAAAA
// Make movement more cohesive (taking notes, adding buffers and stuff)
// Add cooldown to climb, so we don't instantly climb after wall jumping YAAAAAAAAAAAAAAAA
// Reduce hitbox on direction we aren't facing YAAAAAAAAAAAAAAAAAA
// Input handler was saving surface, which lead us to teleport to surface if we hold w and are not on ground, YAAAAAAAAAAAAAAA
// Make climbBox shorter from the bottom
// Dashing changed slightly (equation changed but similar results) YAAAAAAAAAAAAAAAAAAAA
// Dashing didn't change to inAir... had to go through jump to do that, fix YAAAAAAAAAAAAAAAAAAA


// BUGS
// We get stuck on corners sometimes, I think due to our animation, but we should already unstuck ourselves when we change animation, also should also implement not getting stuck to be more aware of the direction we just took, so that it could more accurately unstuck us instead of just taking the shortest distance
// Dash + climb thing where we are at a different x position than the bbox boundary YAAAAAAAAAAAA it was because we didn't check at the end of the frame actually, that could bug out in a lot of ways, maybe all checks should be performed at the end of the frame or the start
// URGENT, MAKE STATES CHECK AT THE SAME TIME WITHOUT CHANGING ANYTHING UNTIL WE ACTUALLY CHANGE THE STATES YAAAAAAAAAAAAAAAAAAAA
// CLamp grav to 28 again YAAAAAAAAAAAAAAAAAAAAa
// Wall jump needs to know which dir to jump in YAAAAAAAAAAAAAAAAAAAAa
// Weird walk bug, where you jitter, it was an old one who's fix i deleted YAAAAAAAAAAAAAAAAAAAAAAa
// THE ULTIMATE BUG, ONE THAT IS NOT MY OWN: SIMULTANEOUS KEY PRESSES OF SPACE, THE RIGHT ARROW KEY, AND ANOTHER KEY MEANS SPACE WILL NOT BE RECOGNISED
// WE SHOULD PROBABLY ONLY UPDATE POSITION AT THE END OF EACH FRAME YAAAAAAAAAAAAAAAAAAAA
// WE CAN'T GO DO THE WHOLE PIPELINE OF ONE ENTITY THEN MOVE ONTO ANOTHER ENTITY, WE NEED TO DO ONE STAGE OF EVERY ENTITY, THEN ANOTHER STAGE OF EVERY ENTITY
// DO ANIM STUFF YAAAAAAAAAAAAAAAAAA
// When we collide with something on the x axis, strange things happen to our walkVel

// CLEAN UP
// In the state machine we have a for loop that we use a lot to determine our state hierarchy, turn it into a function YAAAaaa
// WE ARE MOVING STATE SPECIFIC FUNCTIONS AND VARIABLES TO THE STATE YAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
// BIG RESTRUCTURE LIMIT THE INPUT AND OUTPUT OF STATES, as part of the updLogic pipeline, get the user input, then based on that user input take in contextInput that we might need YAAAAAAAAAAAAAA
// Put the vars of the inputHandler that aren't functions into a 2d array of states and their related vars IM GONNA FOCUS ON ADDING AND IMPROVING FEATURES FOR A WHILE
// Get rid of tempVar YAAAAAAAAAAAAAAAAAAAAAA
// Move some check functions to the base entity state
// FInd better name for checkClimbCont, and the userinput function checkClimb
// Give entity base state the changeState func, and only take reference to the two stateMachine arrays
// Turn persistVar into an enum indexed array, like we did with read and write var

