inputHandler =  {
	projectileInput : false,
	holdInput : false,
}
autonomous = false;
showRequests = false;
projGrav = 9.8;

dirFacing = 0;

xVel = 0;
yVel = 0;

decel = 0.87;



// The struct that changes the player's state, calling states' enter and exit functions
stateMachine = new EntityStateMachine(id);

// STATES
idleState = new IdleState(id, [spr_rocc, spr_rocc]);
projectileState = new ProjectileState(id, [spr_rocc, spr_rocc]);
heldState = new HeldState(id, [spr_rocc, spr_rocc]);
heldState.checkChanges = function() {};
idleCombatState = new IdleCombatState(id, [spr_rocc, spr_rocc]);

idleState.checkChanges1 = function() {};
idleState.checkChanges2 = function() {};

// INITIALISE THE STATE MACHINE
var _startingStates = [idleCombatState, idleState, idleState];
stateMachine.init(_startingStates);









