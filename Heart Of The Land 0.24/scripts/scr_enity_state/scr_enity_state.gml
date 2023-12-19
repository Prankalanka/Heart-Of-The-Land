/// The super class of all entity states.
function EntityState(_id, _anims) constructor {
	// Things that aren't going to change from instance to instance are made static
	entity = _id; // Reference to the player object
	anims = _anims; // Animation specific to that state
	stateMachine = entity.stateMachine; // Reference to the actual state machinestatic
	inRegion = [false, false, false]
	updated = false;
	
	// Use "s" Infront of builtin variable names to prevent overrides, use s also to maintain semantics
	static sEnter = function(_data = undefined) 
	{
		// Could make only specific to animations with differing collision box
		// or just upon every collision box change
		doChecks();
	}
	
	static sExit = function() // Would be a built-in exit keyword override
	{
	}
	
	// Called every frame
	static updLogic = function()
	{
	}
	
	// Called to make sure we can achieve the desired  state
	doChecks = function()  
	{
	}
	
}

