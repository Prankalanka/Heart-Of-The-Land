#region Old Variables
range = 1000;
xMid = x;
xMin = x - range;
xMax = x + range;

targetX = x + 10;
targetY = 0;

xVel = 6;
yVel = 0;

xDir = 0;
yDir = 0;

isBelow =  place_meeting(x, (y + 1), obj_platform);
isAbove = place_meeting(x, (y - 1), obj_platform);

peak = -150;
framesToPeak = 20
initDiveVel = (2 * peak) / framesToPeak;
grav = (2 * peak) / sqr(framesToPeak);

attackCd = true;
//ax
#endregion 

#region Walk State Setup


#endregion

#region Idle State Setup
var _idleAnims =  [spr_idle_right, spr_idle_left];
#endregion

#region Jump / In Air State Setup
var _jumpAnims = [spr_jump_right, spr_jump_left];
var _inAirAnims = [spr_jump_right, spr_jump_left];

// Jump State
var _peak = -200;
var _framesToPeak = 24;
var _initJumpVel = (2 * _peak) / _framesToPeak + _peak/sqr(_framesToPeak);
var _grav = (2 * _peak) / sqr(_framesToPeak); // in Air State also

// In Air State
var _coyoteMax = 90;
var  _yVelMax = 30;
var _coyoteDistMax = 40;

var _inAirData = [_grav, _coyoteMax, _yVelMax, _coyoteDistMax];
var _jumpData = [_peak, _framesToPeak, _initJumpVel, _grav, _yVelMax];
#endregion

#region Idle Combat Setup 
var _checkSetHeld = function() {
	if place_meeting(x, y, par_throwable) {
		var _held = instance_nearest(x, y, par_throwable);
					
		// Done here so they're at the hold and held states at the same time
		stateMachine.requestChange(SH.HOLD, 0, [_held]);
		_held.stateMachine.requestChange(SH.HELD, 0, [id]);
		_held.stateMachine.requestChange(SH.HELD, 1, [id]);
		_held.stateMachine.requestChange(SH.HELD, 2, [id]);
	}
}

var _idleCombatData = [_checkSetHeld];
#endregion

#region Input Handler Setup
inputHandler = 
{	
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
	
	/// Check every input in the inputFunctions array
	checkUserInputs : function() {	
		var _len = array_length(inputFunctions);
		
		for (var i = 0; i < _len; i++) {
			inputFunctions[i]();
		}
	},
}

inputHandler.inputFunctions = [inputHandler.checkWalk, inputHandler.checkJump];
#endregion

#region Persistant Variable Setup (Holds variables that the states need to read/write to, that multiple states need)
persistVar = { 
	colliderArray : [obj_platform, obj_block],
	isBelow : false,
	isAbove : false,
	indexFacing : 0,
	
	xVel : 0,
	yVel : 0,
	
	x : x,
	y : y,
}

#endregion

#region New Entity Functions

#endregion

#region State Machine, State Creation, and Initialisation
activeStates = undefined;
prioState = undefined;

canShowRequests = false;
canShowStates = false;

stateMachine = new EntityStateMachine();

states = [];

//  Takes specific entity data as input, alters the entity's and its own data depending on input.
// Specifically, they can alter which states are active, leading to major behavioural changes.
states[SH.IDLE] = new IdleState(persistVar, stateMachine, inputHandler, _idleAnims);
states[SH.WALK] = new WalkState(persistVar, stateMachine, inputHandler, _walkAnims, _walkData);
states[SH.INAIR] =  new InAirState(persistVar, stateMachine, inputHandler, _inAirAnims, _inAirData);
states[SH.JUMP] = new JumpState(persistVar, stateMachine, inputHandler, _jumpAnims, _jumpData); 
states[SH.IDLECOMBAT] = new IdleCombatState(persistVar, stateMachine, inputHandler, _idleAnims, _idleCombatData);

// Initialise
var _startingStates = [states[SH.IDLECOMBAT], states[SH.IDLE], states[SH.IDLE]];
initStates(_startingStates);
#endregion