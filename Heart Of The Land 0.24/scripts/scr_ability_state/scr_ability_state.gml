/// Super class for all ability states
/// Switches to either Idle, Move or InAir states once ability is done
function AbilityState(_id, _animName) : EntityState(_id, _animName) constructor{
	static stateSEnter = sEnter;
	
	isAbilityDone = false;
	
	static sEnter = function() {
		stateSEnter();
		isAbilityDone = false;
	}
	
	static updLogic = function() {
		// Change state once ability is done
		if isAbilityDone {
			if inRegion[1] {
				if entity.xVel == 0 and entity.inputHandler.xInputDir == 0 {
					stateMachine.changeState(entity.idleState, 1);
				} else {
					stateMachine.changeState(entity.moveState, 1);
				}
			} 
			
			if inRegion[2] {
				if !entity.isBelow {
					stateMachine.changeState(entity.inAirState, 2);
				}
				else {
					if entity.xVel == 0 and entity.inputHandler.xInputDir == 0 {
						stateMachine.changeState(entity.idleState, 2);
					} else {
						stateMachine.changeState(entity.moveState, 2);
					}
				}
			}
		}
	}
}

function JumpState(_id, _animName) : AbilityState(_id, _animName) constructor {
	static name = "Jump";
	static num = 4;
	static abilitySEnter = sEnter;
	static abilityUpdLogic = updLogic;
	
	// Probably injected in the future for different jump heights between different jump states
	peak = -330;
	framesToPeak = 30
	initJumpVel = (2 * peak) / framesToPeak + peak/sqr(framesToPeak);
	
	static sEnter = function() {
		abilitySEnter();
		
		
		
		// Set input values (these handle if we're continuing a jump or not)
		entity.inputHandler.spaceReleasedSinceJump = false;
		entity.inputHandler.currJumpFrame = 1;
		entity.inputHandler.jumpBuffer = 0;
	}
	
	static updLogic = function() {
		// Set velocity and spaceReleased
		entity.yVel = initJumpVel;
	
		// Update yVel and Y
		entity.updYVel(-1);
		with(entity){updY();}
		
		
		// Change to other state, this one is only active for one frame
		isAbilityDone = true;
		abilityUpdLogic();
	}

}

function DashState(_id, _animName) : AbilityState(_id, _animName) constructor {
	static name = "Dash";
	static num = 3;
	static abilitySEnter = sEnter;
	static abilityUpdLogic = updLogic;
	dir = 0;
	dashFrame = 0;
	
	static sEnter = function() {
		// Reset ability done
		abilitySEnter();
		
		// Update dir
		dir = entity.inputHandler.xInputDir * -1;
		
		// Reset dashFtame
		dashFrame = 0;
	}
	
	static updLogic = function() {
		 // Increment to move along the graph
	    // Start at 1 cuz 0 makes xVel equal 0
	    dashFrame += 1;
		
		entity.xVel =  ( 1 / 40 * power((dashFrame * 2 - 30), 2) - 20.5) * dir;
		
	    // On the 15th frame we also change state to base, which resets variables for us
		// I think checks like this will be in the doChecks() function of the state
	    if dashFrame == 15 {
	        // Change to other state, this one is only active for one frame
			isAbilityDone = true;
			abilityUpdLogic();
	    }
		
		with(entity){updX(dashState.dir * -1);}
	}
	
	static sExit = function() {
		entity
	}
}