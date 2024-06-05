enum SH {
	// Region 1 States (can be multi-region when grounded but clearer this way)
	IDLECOMBAT,
	IDLE,
	WALK,
	DASH,
	
	AIRDASH,
	
	// Region 2 States
	INAIR,
	CLIMB,
	JUMP,
	WALLJUMP,
	
	// Multi-Region States
	PROJECTILE,
	
	// Region 3 States
	HOLD,
	HELD,
}

/// Stores state changes and their data
function EntityStateMachine() constructor {
	stateChanges = [[], [], []]; // An array per region
	stateChanged = false;
	changeData = [];
	stateNameArray = [
	"Idle Combat",
	"Idle",
	"Walk",
	"Dash",
	
	"Air Dash",
	
	// Region 2 States
	"InAir",
	"Climb",
	"Jump",
	"Wall Jump",
	
	// Multi-Region States
	"Projectile",
	
	// Region 3 States
	"Hold",
	"Held",
	];

	/// Sets stateChanged to true, puts a requested state in the stateChanges 2D array, based on region, and contains any data in the changeData array
	static requestChange = function(_newStateNum, _region, _data = undefined)
	{
		stateChanged = true;
		
		// Push state onto the region array of stateChanges so we change state after this frame
		array_push(stateChanges[_region], _newStateNum);
		
		if _data != undefined {
			changeData[_newStateNum] =  _data;
		}
	}
	
	/// Display the region and names of all requested states of that region
	static showRequest =  function(_element, _index) {
		if array_length(stateChanges[_index]) != 0 {
			var _nameArray = [];
			
			for (var i = 0; i < array_length(stateChanges[_index]); i++) {
				array_push(_nameArray, stateNameArray[stateChanges[_index][i]]);
			}
			
			var _nameString = $"Region {_index}: " + string(_nameArray);
			show_debug_message(_nameString);
		}
	}
	
	/// Display all regions that have one or more requested change
	static showRequests =  function() {
		if stateChanged {	
			show_debug_message($"Time: {time_source_game}");
			array_foreach(stateChanges, showRequest);
		}
	}
}

#region State Functions
/// In its own function so states don't have to be defined when we create the stateMachine.
/// Sets activeStates to arguments, enters and regions the activeStates, and sets prioState
function initStates(_startingStates) {
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
function execPipeLine() {
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
function updLogic() {
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
function updPos() {
	// Update Position (states only control velocity)
	if persistVar.xVel != 0 {updX();}
	if persistVar.yVel != 0 {updY();}
}

// Set arguments to their respective variables
function updAnim(_spriteIndex = undefined, _imageIndex = undefined, _imageSpeed = undefined) {
	// GONNA BE FUNC OF ENTITY
	if _spriteIndex != undefined {
		var _prevBBox = [bbox_left, bbox_top, bbox_right, bbox_bottom];
		sprite_index = _spriteIndex;
		var _currBBox = [bbox_left, bbox_top, bbox_right, bbox_bottom];
		
		var _differences = [0,0,0,0];
		
		for (var i = 0; i < array_length(_prevBBox); i++) {
			_differences[i] = _prevBBox[i] - _currBBox[i];
		}
		
		checkSpriteStuck(_differences);
	}
	if _imageIndex != undefined {
		image_index = _imageIndex; // Face correctly
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
function changeStates() {
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
					if array_length(_changeData) >= _prioState.num + 1 and _changeData[_prioState.num] != 0 {
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
function checkChanges() {
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
function isDuplistate(_state) {
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
function getPrioState(_nums) {
	// Figure out which state in the hierarchy we should have the animation of
	return states[script_execute_ext(max, _nums)];
}

/// Display the names of each currentState in the console
function showStates() {
	var _currentNames = [undefined, undefined, undefined];
	for (var i = 0; i < array_length(activeStates); i++) {
		_currentNames[i] = activeStates[i].name;
	}
	show_debug_message(_currentNames);
}
#endregion
