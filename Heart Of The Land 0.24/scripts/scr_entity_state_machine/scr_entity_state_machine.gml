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