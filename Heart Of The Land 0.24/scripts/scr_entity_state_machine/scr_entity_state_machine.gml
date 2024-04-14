enum STATEHIERARCHY {
	// Region 1 States (can be multi-region when grounded but clearer this way)
	idleCombat,
	idle,
	walk,
	dash,
	
	// Region 2 States
	inAir,
	climb,
	jump,
	wallJump,
	
	// Multi-Region States
	projectile,
	
	// Region 3 States
	hold,
	held,
	
}


/// The class of all entity state machines.
function EntityStateMachine(_entity) constructor {
	currentStates = undefined;
	nextStates = [[], [], []]; // An array per region
	stateChanged = false;
	changeData = [];
	prioState = undefined;
	entityShowStates = _entity.showStates;
	entityShowRequests = _entity.showRequests
	blackBoard = {} // A struct containing the shared input and output of all states
	
	/// In its own function so states don't have to be defined when we create the stateMachine.
	/// Sets currentStates to arguments, enters and regions the currentStates, and sets prioState
	static init = function(_startingStates)
	{
		currentStates = _startingStates;
		
		// Enter aand region all current states
		for (var i = 0; i < array_length(currentStates); i++) {
			currentStates[i].inRegion[i] = true;
			currentStates[i].sEnter();
		}
		
		// Figure out which state in the hierarchy we should have the animation of
		prioState = getPrioState(currentStates);
	}

	/// Checks what changes the current states are requesting, changes the requesting states and possibly the priority state depending on hierarchy. 
	/// Does the updLogic for each state, and finally does the updAnim function for the priority state.
	 static updLogic = function() {
		 
		// Resets so we can tell which ones are unique again
		for (var i = 0; i < array_length(currentStates); i++) {
			currentStates[i].checked = false;
		}
		
		// Does the doCheck function for each unique state once
		// If we do it per state, they might not have the same context to check from
		for (var i = 0; i < array_length(currentStates); i++) {
			if !currentStates[i].checked {
				currentStates[i].checkChanges();
				currentStates[i].checked = true;
			}
		}
		
		 if entityShowRequests {
			 showRequests();
		 }
		 
		changeStates();
		 
		  if entityShowStates {
			 showStates();
		 }
		 
		 // Resets so we can tell which ones are unique again
		for (var i = 0; i < array_length(currentStates); i++) {
			currentStates[i].updated = false;
		}
		
		// Does the update logic for each unique state once
		for (var i = 0; i < array_length(currentStates); i++) {
			if !currentStates[i].updated {
				currentStates[i].updLogic();
				currentStates[i].updated = true;
			}
		}
		
		// Update animation once all the context has been decided
		prioState.updAnim();
	 }
	
	/// Sets stateChanged to true, puts a requested state in the nextStates 2D array, based on region, and contains any data in the changeData array
	static requestChange = function(_newState, _region, _data = undefined)
	{
		stateChanged = true;
		
		// Push state onto the region array of nextStates so we change state after this frame
		array_push(nextStates[_region], _newState);
		
		if _data != undefined {
			changeData[_newState.num] =  _data;
		}
		
	}
	
	/// If stateChanged is true, for every non-empty region of nextStates, check which requested state is highest in the hierarchy.
	/// Possibly call the enter and exit functions of the requested and requesting states respectively, whilst always changing the inRegion values.
	/// After looping through all regions, set the prioState and reset the stateChanged, nextStates, and changeData variables.
	static changeStates = function() {
		if stateChanged {
			for (var i = 0; i < array_length(nextStates); i++) {
				// If the region's array of states we want to change to is not empty
				if array_length(nextStates[i]) != 0 {
					
					// Sort by hierarchy
					var _prioState = getPrioState(nextStates[i]);
					
					// If current state isn't a duplistate do the exit function for that state
					if !isDuplistate(currentStates[i]) {
						currentStates[i].sExit();	
					}
					
					// Set current and next state inRegion values
					currentStates[i].inRegion[i] = false;
					currentStates[i] = _prioState;
					currentStates[i].inRegion[i] = true;
					
					// If new state isn't a duplistate do the enter function for that state
					if !isDuplistate(currentStates[i]) {
						if array_length(changeData) != 0 and changeData[_prioState.num] != undefined {
							currentStates[i].sEnter(changeData[_prioState.num]);
						}
						else {
							currentStates[i].sEnter();
						}
					}
				}
			}
			prioState = getPrioState(currentStates);
			
			// Reset
			stateChanged = false;
			nextStates = [[], [], []];
			changeData = [];
		}
	}
	
	/// Check if the input state, is found multiple times in the currentStates array
	static isDuplistate = function(_state) {
		var _count = 0;
		for (var i = 0; i < array_length(currentStates); i++) {
			if currentStates[i] == _state{
				_count++;
				if _count >= 2 {
					return true;
				}
			}
		}
		return false;
	}
	
	/// Return which state of currentStates is highest in the hierarchy 
	static getPrioState = function(_states) {
		// Figure out which state in the hierarchy we should have the animation of
		var _prioState = undefined;
		for (var i = 0; i < array_length(_states); i++) {
			if _prioState != undefined and _states[i].num > _prioState.num {
				_prioState = _states[i];
			} else if _prioState == undefined {
				_prioState =  _states[i];
			}
		}
		return _prioState;
	}
	
	/// Display the names of each currentState in the console
	static showStates = function() {
		var _currentNames = [undefined, undefined, undefined];
		for (var i = 0; i < array_length(currentStates); i++) {
			_currentNames[i] = currentStates[i].name;
		}
		show_debug_message(_currentNames);
	}
	
	/// Display the region and names of all requested states of that region
	static showRequest =  function(_element, _index) {
		if array_length(nextStates[_index]) != 0 {
			var _nameArray = [];
			
			for (var i = 0; i < array_length(nextStates[_index]); i++) {
				array_push(_nameArray, nextStates[_index][i].name);
			}
			
			var _nameString = $"Region {_index}: " + string(_nameArray);
			show_debug_message(_nameString);
		}
	}
	
	/// Display all regions that have one or more requested change
	static showRequests =  function() {
		if stateChanged {	
			show_debug_message($"Time: {time_source_game}");
			array_foreach(nextStates, showRequest);
		}
	}
}