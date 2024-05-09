inputHandler =  {
	projectileInput : false,
	holdInput : false,
}
showRequests = false;
projGrav = 9.8;

indexFacing = 0;

xVel = 0;
yVel = 0;

decel = 0.87;



// The struct that changes the player's state, calling states' enter and exit functions
stateMachine = new EntityStateMachine(id);

// STATES
idleState = new IdleState(persistVar, stateMachine, inputHandler [spr_rocc, spr_rocc]);
projectileState = new ProjectileState(persistVar, stateMachine, inputHandler [spr_rocc, spr_rocc]);
heldState = new HeldState(persistVar, stateMachine, inputHandler [spr_rocc, spr_rocc]);
heldState.checkChanges = function() {};
idleCombatState = new IdleCombatState(persistVar, stateMachine, inputHandler [spr_rocc, spr_rocc]);

idleState.checkChanges1 = function() {};
idleState.checkChanges2 = function() {};

// INITIALISE THE STATE MACHINE
var _startingStates = [idleCombatState, idleState, idleState];
stateMachine.init(_startingStates);









