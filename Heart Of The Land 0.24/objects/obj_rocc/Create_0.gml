inputHandler =  {
	projectileInput : false,
}
autonomous = false;
projGrav = 9.8;

lastDirFaced = 0;

xVel = 0;
yVel = 0;



// The struct that changes the player's state, calling states' enter and exit functions
stateMachine = new EntityStateMachine();

// STATES
idleState = new IdleState(id, [spr_rocc, spr_rocc])
projectileState = new ProjectileState(id, [spr_rocc, spr_rocc]);

// INITIALISE THE STATE MACHINE
var _startingStates = [idleState, idleState, idleState];
stateMachine.init(_startingStates);









