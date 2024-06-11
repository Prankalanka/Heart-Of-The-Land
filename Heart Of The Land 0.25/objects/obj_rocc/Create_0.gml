
#region Input Handler Setup
inputHandler = {
	xInputDir : 0,
	projectileInput : false,
	holdInput : false,

/// Check every input in the inputFunctions array
	checkUserInputs : function() {	
		var _len = array_length(inputFunctions);
		
		for (var i = 0; i < _len; i++) {
			inputFunctions[i]();
		}
	},
}

inputHandler.inputFunctions = [];
inputHandler.checkContextInputs = function() {
}
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

var _idleAnims = [spr_rocc, spr_rocc];

var _projGrav = 9.8;
var _projDecel = 0.87;

var _projData = [_projGrav, _projDecel];
	
var _checkSetHeld = function() {
	if place_meeting(x, y, par_throwable) {
		var _held = instance_nearest(x, y, par_throwable);
					
		// Done here so they're at the hold and held states at the same time
		stateMachine.requestChange(holdState, 0, [_held]);
		_held.stateMachine.requestChange(_held.heldState, 0, [id]);
		_held.stateMachine.requestChange(_held.heldState, 1, [id]);
		_held.stateMachine.requestChange(_held.heldState, 2, [id]);
	}
}

var _idleCombatData = [_checkSetHeld];


#region State and State Machine Setup

activeStates = undefined;
prioState = undefined;

canShowRequests = true;
canShowStates = false;

stateMachine = new EntityStateMachine();

states = [];

states[SH.IDLE] = new IdleState(persistVar, stateMachine, inputHandler, _idleAnims);
states[SH.PROJECTILE] = new ProjectileState(persistVar, stateMachine, inputHandler, _idleAnims, _projData);
states[SH.IDLECOMBAT] = new IdleCombatState(persistVar, stateMachine, inputHandler, _idleAnims, _idleCombatData);
states[SH.HELD] = new HeldState(persistVar, stateMachine, inputHandler, _idleAnims); 

// Set Transitions
states[SH.HELD].checkChanges = function() {};
states[SH.IDLE].checkChanges = function() {};

// INITIALISE THE STATE MACHINE
var _startingStates = [states[SH.IDLECOMBAT], states[SH.IDLE], states[SH.IDLE]];
initStates(_startingStates);
#endregion








