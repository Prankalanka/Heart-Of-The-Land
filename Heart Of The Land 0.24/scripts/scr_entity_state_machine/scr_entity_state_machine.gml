/// The class of all entity state machines.
function EntityStateMachine() constructor {
	// 2D array of states we want to transition to that frame, an array per region
	nextStates = [[], [], []];
	currentStates = undefined;
	stateChangedLastFrame = false;
	stateHierarchy = ["Idle", "Move", "InAir", "Dash", "Jump"]; // MAKE STATE NUMS BASED ON THIS 
	
	static init = function(_startingStates)
	{
		currentStates = _startingStates;
		
		// Enter all current states
		for (var i = 0; i < array_length(currentStates); ++i) {
			currentStates[i].inRegion[i] = true;
			currentStates[i].sEnter();
		}
		
	}

	static changeState = function(_newState, _region, _dir = 0)
	{
		stateChangedLastFrame = true;
		
		//show_debug_message(stateHierarchy[currentStates[_region].num]);
		//show_debug_message(stateHierarchy[_newState.num]);
		// Push state onto the region array of nextStates so we change state after this frame
		array_push(nextStates[_region], _newState);
		
	}
	
	 static updLogic = function(){
		 
		 	if stateChangedLastFrame {
				for (var i = 0; i < array_length(nextStates); i++) {
					// If the region's array of states we want to change to is not empty
					if array_length(nextStates[i]) != 0 {
					
						// Sort by hierarchy
						var _priorityState = undefined;
						for (var j = 0; j < array_length(nextStates[i]); j++) {
							if _priorityState != undefined and nextStates[i][j].num > _priorityState.num {
								_priorityState = nextStates[i][j];
							} else if _priorityState == undefined {
								_priorityState =  nextStates[i][j];
							}
						}
					
						// If current state isn't a duplistate do the exit function for that state
						if !isDuplistate(currentStates[i]) {
							currentStates[i].sExit();	
						}
				
						// Set current and next state inRegion values
						currentStates[i].inRegion[i] = false;
						currentStates[i] = _priorityState;
						currentStates[i].inRegion[i] = true;
					
						// If new state isn't a duplistate do the enter function for that state
						if !isDuplistate(currentStates[i]) {
							currentStates[i].sEnter();
						}
					
						// Figure out which state in the hierarchy we should have the animation of
						_priorityState = undefined;
						for (var j = 0; j < array_length(currentStates); j++) {
							if _priorityState != undefined and currentStates[j].num > _priorityState.num {
								_priorityState = currentStates[j];
							} else if _priorityState == undefined {
								_priorityState =  currentStates[j];
							}
						}
					
						// Change animation
						_priorityState.entity.prioStateAnims = _priorityState.anims;
						_priorityState.entity.sprite_index =  _priorityState.anims[_priorityState.entity.lastDirFaced];
						with _priorityState.entity {checkStuck();}
						//show_debug_message(_priorityState.name);
					
					}
				}
				stateChangedLastFrame = false;
			}
		 
		 // Reset Next States
		 nextStates = [[],[],[]];
		 
		// Does the update logic for each unique state once
		for (var i = 0; i < array_length(currentStates); i++) {
			if !currentStates[i].updated {
				currentStates[i].updLogic();
				currentStates[i].updated = true;
			}
		}
		
		//showNames();
		
		// Resets so we can tell which ones are unique again
		for (var i = 0; i < array_length(currentStates); i++) {
			currentStates[i].updated = false;
		}
		
	 }
	
	static showNames = function() {
		var _currentNames = [undefined, undefined, undefined];
		for (var i = 0; i < array_length(currentStates); i++) {
			_currentNames[i] = currentStates[i].name;
		}
		show_debug_message(_currentNames);
	}
	
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
	
}