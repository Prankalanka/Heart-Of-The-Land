/// Super class for all ability states
/// Switches to either Idle, Move or InAir states once ability is done
function AbilityState(_id, _animName) : EntityState(_id, _animName) constructor{
	static stateSEnter = sEnter;
	
	isAbilityDone = false;
	
	static sEnter = function(_data = undefined) {
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
					stateMachine.changeState(entity.walkState, 1);
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
						stateMachine.changeState(entity.walkState, 2);
					}
				}
			}
		}
	}
}

function JumpState(_id, _animName) : AbilityState(_id, _animName) constructor {
	static name = "Jump";
	static num = STATEHIERARCHY.jump;
	static abilitySEnter = sEnter;
	static abilityUpdLogic = updLogic;
	
	// Probably injected in the future for different jump heights between different jump states
	peak = entity.peak;
	framesToPeak = entity.framesToPeak;
	initJumpVel = entity.initJumpVel;
	
	static sEnter = function(_data = undefined) {
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
		entity.updYVel();
		with(entity){updY();}
		
		
		// Change to other state, this one is only active for one frame
		isAbilityDone = true;
		abilityUpdLogic();
	}

}

function DashState(_id, _animName) : AbilityState(_id, _animName) constructor {
	static name = "Dash";
	static num = STATEHIERARCHY.dash;
	static abilitySEnter = sEnter;
	static abilityUpdLogic = updLogic;
	dir = 0;
	dashFrame = 0;
	
	static sEnter = function(_data = undefined) {
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
			
			if abs(entity.xVel) >= entity.xVelClamp {
				stateMachine.changeState(entity.walkState, 1);
			}
	    }
		
		with(entity){updX(dashState.dir * -1);}
	}
	
	static sExit = function() {
	}
}


function ProjectileState(_id, _animName) : AbilityState(_id, _animName) constructor {
	static name = "Projectile";
	static num = STATEHIERARCHY.projectile;
	static abilitySEnter = sEnter;
	static abilityUpdLogic = updLogic;

	projectileFrame = 0;
	
	angle = 0;
	initVel = 5;
	areAxesOpposite = 1;
	multi = 1;
	
	xVel = 0;
	yVel = 0;
	lastXPos = 0;
	lastYPos = 0;
	initPos = [];
	
	static updLogic = function() {
		updProjectileVel();
		
		with entity {
			updX(sign(xVel));
			updY();
		}
	}
	
	static sEnter = function(_data = undefined) {
		abilitySEnter();
		// Enter the state and set the angle and set angle and initial velocity 
		// Set it through the player's vars
		
		initVel = _data[0];
		angle = _data[1];
		multi = _data[2];
		areAxesOpposite = _data[3];
		
		initPos = [entity.x, entity.y];
		projectileFrame = 0;
		lastXPos = 0;
		lastYPos = 0;
	}
	
	static updProjectileVel = function() {
		show_debug_message([initVel, angle]);
		// For 100 frames
		if projectileFrame < 100 {
			
			// Find the next position we're going to
			var _nextXPos = initVel * projectileFrame * cos(angle) * areAxesOpposite;
			var _nextYPos = (initVel * projectileFrame *  sin(angle) - (1/2) *  -entity.projGrav * sqr(projectileFrame));
			
			// Make the xVel the difference between the next position and the last position
			entity.xVel = _nextXPos - lastXPos;
			entity.yVel = _nextYPos - lastYPos;
			
			// Make the next position the last position, storing to be used at the start of the next frame
			lastXPos = _nextXPos;
			lastYPos = _nextYPos;
			
			projectileFrame += 1 * multi;
		}
		else {
			entity.xVel = entity.xVel * entity.decel;
			entity.yVel = entity.yVel * entity.decel;
		}
	}
	
	static drawPath = function() {
		totalTime = 100;
		var _lastXPos = entity.x;
		var _lastYPos = entity.y;
		
		for (var i = 0; i < totalTime; i += 1 * multi) {
			var _nextXPos = initVel * i * cos(angle) * areAxesOpposite + initPos[0];
			var _nextYPos = (initVel * i * sin(angle) - (1/2) * -entity.projGrav * sqr(i)) + initPos[1];
			
			draw_line(_lastXPos, _lastYPos, _nextXPos, _nextYPos);
			
			_lastXPos = _nextXPos;
			_lastYPos = _nextYPos;
		}
	}
}

function HeldState(_id, _animName) : AbilityState(_id, _animName) constructor {
	static name = "Held";
	static num = STATEHIERARCHY.held;
	holder = undefined;
	
	static sEnter = function(_data) {
		holder = _data;
	}
	
	static updLogic = function() {
		entity.x = holder.x;
		entity.y = holder.y
	}
}
