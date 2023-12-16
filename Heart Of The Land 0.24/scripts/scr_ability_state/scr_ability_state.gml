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
	static num = 4;
	static abilitySEnter = sEnter;
	static abilityUpdLogic = updLogic;
	
	// Probably injected in the future for different jump heights between different jump states
	peak = -330;
	framesToPeak = 30;
	initJumpVel = (2 * peak) / framesToPeak + peak/sqr(framesToPeak);
	
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
	static num = 3;
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
	static num = 5;
	static abilitySEnter = sEnter;
	static abilityUpdLogic = updLogic;
	
	// Probably injected in the future for different projectile heights between different jump states
	thrower = undefined;
	projectileFrame = 0;
	angle = 0;
	dangle = 0;
	initVel = 50;
	xVel = 0;
	yVel = 0;
	lastXPos = 0;
	lastYPos = 0;
	
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
		angle = degtorad(_data[1]);
		projectileFrame = 0;
		lastXPos = 0;
		lastYPos = 0;
	}
	
	static updProjectileVel = function() {
		
		if projectileFrame < 100 {
			
			var _nextXPos = initVel * projectileFrame * cos(angle);
			var _nextYPos = initVel * projectileFrame * sin(angle) - (1/2) * -entity.projGrav * sqr(projectileFrame);
			
			entity.xVel = _nextXPos - lastXPos;
			entity.yVel = _nextYPos - lastYPos;
			
			lastXPos = _nextXPos;
			lastYPos = _nextYPos;
			
			projectileFrame++
		}
		
	}
	
	static drawPath = function() {
		totalTime = 10;
		var _lastXPos = entity.x;
		var _lastYPos = entity.y;
		
		for (var i = 0; i < totalTime; i++) {
			var _nextXPos = initVel * i * cos(angle) + entity.x;
			var _nextYPos = (initVel * i * sin(angle) - (1/2) * -entity.projGrav * sqr(i)) + entity.y;
			
			draw_line(_lastXPos, _lastYPos, _nextXPos, _nextYPos);
			
			_lastXPos = _nextXPos;
			_lastYPos = _nextYPos;
		}
	}
	
	static throwProjectile = function (_proj, _targetPos, _angle) {
		// WE'RE USING RADIANS
		// Find initVel
		initVel = sqrt((sqr(_targetPos[0]) * _proj.projGrav) / (2 * _targetPos[0] * sin(_angle) * cos(_angle) - 2 * _targetPos[1] * sqr(cos(_angle))));
		
		time = _targetPos[0] / (initVel * cos(_angle));
		_proj.stateMachine.changeState(_proj.projectileState, 2, [initVel, _angle]);
	}
	
	
}