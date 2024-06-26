/// Takes specific entity data as input, alters the entity's and its own data depending on input.
/// Specifically, it can alter which states are active, leading to major behavioural changes.
function EntityState(_persistVar, _stateMachine, _inputHandler, _anims, _data = undefined) constructor {
	persistVar = _persistVar; // Contains variables specific to the entity that states can modify
	stateMachine = _stateMachine;
	inputHandler = _inputHandler;
	anims = _anims; // All anims we can switch to within the state
	activeAnims = anims; // Current anims, that we switch between based on indexFacing
	inRegion = [false, false, false]; // Which region(s) the state is in
	// Bools so we don't run duplistate updLogic or checkChanges functions multiple times
	updated = false; 
	checked = false;
	
	/// Called the first frame of a state, each time it is newly active
	static sEnter = function(_data = undefined) {
		
	}
	
	/// Called the last frame of a single instance of a state
	static sExit = function() { // Would be a built-in exit keyword override
	
	}
	
	/// All logic for updating the entity's and state's variables, called every frame
	static updLogic = function() {
	
	}
	
	// Change anim when our state first begins
	static getAnimEnter = function() {
	}
	
	// Change anim when our state first begins
	static getAnimExit = function() {
		return activeAnims[faceDir(inputHandler.xInputDir)];
	}
	
	/// All logic for updating a state's animations, normally including a faceDir and checkStuck call. Called every frame
	static getAnimUpd = function() {
		
	}
	
	/// A non-static function, meaning it can vary from object to object, containing the logic for checking all possible changes a state can make
	checkChanges = function() {
		
	}
		
	/// Static check functions, they contain the logic for a single possible change. Named after the state(s) they change to, or their cause, and the region(s) they affect
	// Something like checkWalk1 or checkCollision12
	
	/// Additional state functions, specific to a state and its variables, and normally used multiple times or just big hence why they're functions
	// Something like updCoyote for the inAir state or quadraticEquation for the holdState T-T
}

