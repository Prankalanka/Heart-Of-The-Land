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
	
	xForces = [[0], 0];
	xRepeatAccel = 0;
	
	yForces = [[0], 0, 0];
	yRepeatAccel = 0;
	
	timeMulti = 1; // 1 is 100% 2 is 200% 0.1 is 10%
	framesToRepeat = 0;
	
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
		/*
		
		// Should forces be unseperated since we add
		
		// Say we have just thrown the object at force1, it's acceleration is instantly 10,-9
		force = [10, -9];
		// Our acceleration is then left to drag and gravity and it starts deceleratubg both 
		force = [-1, 3];
		// The acceleration of gavity stays constant whilst drag's grows
		force = [-2, 3];
		
		// If we've repeated our accel enough
		// Recalculate the repeatAccel and framesToRepeat
		if framesToRepeat == 0 {
			
			var xNetAccel = calculateNetAccel(xForces);
			var yNetAccel = calculateNetAccel(yForces);
			
			framesToRepeat = 1/timeMulti; // Set how many times we repeat to how many times we need to how many times our time multiplier value fits into 1
			
			xRepeatAccel = xNetAccel / framesToRepeat; 
			yRepeatAccel = yNetAccel / framesToRepeat; 
		}
		
		entity.xVel += xRepeatAccel;
		entity.yVel += yRepeatAccel;
		
		with entity {
			updX(sign(xVel));
			updY();
		}
		
		framesToRepeat -= 1;
		*/
		// two options
		// if we use accel
		
		
		// To change how fast the simulation is we'd check if our framesToRepeat value is 0
		// If it is calculate the netAccel and multiply it by the 1/timeMulti which gives us the a fraction of the nextAccel value for that repeated frame
		// Store that vlaue so that we don't calculate it again and add it to the yVel
		// Then set framesToRepeat to 1/timeMulti
		// Decrement it every frame and whilst it isn't 0 repeat the addition
		
		
		// For 100 frames
		if projectileFrame < 100 {
			
			projectileFrame += 1 * multi;
			// Find the next position we're going to
			var _nextXPos = (initVel) * projectileFrame *cos(angle) * areAxesOpposite;
			var _nextYPos = (initVel) * projectileFrame * sin(angle) - (1/2)*  -entity.projGrav * sqr(projectileFrame);
			
			// Make the xVel the difference between the next position and the last position
			entity.xVel = _nextXPos - lastXPos;
			entity.yVel = _nextYPos - lastYPos;
			
			// Make the next position the last position, storing to be used at the start of the next frame
			lastXPos = _nextXPos;
			lastYPos = _nextYPos;
			
			
		// Testing for how multiple forces affect the sequence of our velocity
		// There are a few options:
		// Not scaling with multi at all which will keep the velocity value constant
		// Scaling with multi through addition, not tested but probably similar to multiplication
		// Scaling with multi through multiplication, which makes the sequence linear
		// Scaling with multi through squaring, which makes the sequence quadratic 
		// Scaling with multi through cubing, which makes the sequence cubic
		
		// We probably only need to scale with squaring, so our velocity sequence is quadratic and only has 2 differences
		
		var _y1 = (initVel) * (multi * 1) * sin(angle) - (1/2) *  -entity.projGrav * sqr(multi * 1); //- (1/2) * power(multi * 1, 2);
		var _y2 = (initVel) * (multi * 2) * sin(angle) - (1/2) *  -entity.projGrav * sqr(multi * 2); //- (1/2) * power(multi * 2, 2);
		var _y3 = (initVel) * (multi * 3) * sin(angle) - (1/2) *  -entity.projGrav * sqr(multi * 3); //- (1/2) * power(multi * 3, 2);
		var _y4 = (initVel) * (multi * 4) * sin(angle) - (1/2) *  -entity.projGrav * sqr(multi * 4); //- (1/2) * power(multi * 4, 2);
		
		var _y12Diff = _y1 - _y2;
		var _y23Diff = _y2 - _y3;
		var _y34Diff = _y3 - _y4;
		var diffOfDIff1 = _y12Diff - _y23Diff;
		var diffOfDIff2 = _y23Diff - _y34Diff;
		var _thirdDiff = diffOfDIff1 - diffOfDIff2;
		
		// The current velocity is the initial velocity subtracted by an acceleration that scales with projectileFrame
		var _yVel = _y1 - diffOfDIff1 * (projectileFrame/multi -1);
		
		show_debug_message(string_format(entity.y, 4, 10));
		show_debug_message( [diffOfDIff1,
		string_format(_y1 - diffOfDIff1* (projectileFrame/multi - 1) , 4, 10),
		string_format(entity.yVel, 4, 10) 
		]);
			
		}
		/*
		 initVel * cos(angle) * (i+1) - initVel * cos(angle) * i = nextYVel1
		 initVel * cos(angle) ((i+1) - i)
		 initVel * cos(angle) ((i+1) - (i+1) -1)
		 initVel * cos(angle) (-1) 
		 
		 initVel * cos(angle) * -2 
		 
		 initVel * cos(angle) * (i+2) - initVel * cos(angle) * (i+1) = nextYVel2
		 ( initVel * cos(angle) * (i+2) - initVel * cos(angle) * (i+1) ) - initVel * cos(angle) * (i+2) - initVel * cos(angle) * (i+1) = nextAccel
		 
		 i+1 = i + 1
		 i+2 = i+1 + 1 = i + 2
		 
		 i 
		 
		 ((initVel) * i * sin(angle) - (1/2) *  -entity.projGrav * sqr(i)) - ((initVel) * (i+1) * sin(angle) - (1/2) *  -entity.projGrav * sqr((i+1)));
		 initVel * sin(angle) (i)  - (1/2) * -entity.projGrav (sqr(i)) - i
		 initVel * 1 
		 
		 */
		
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
	
	static calculateNetAccel = function(_forces) {
		var netAccel = 0;
		// Find net acceleration of axis by looping through each force in the array
		// Special case for looping through nested array of thrust forces 
		for (var i = 0; i < array_length(_forces); i++) {
			if i == 0 {
				for (var j = 0; j < array_length(_forces[i]); j++) {
					netAccel += _forces[i][j];
				}
			}
			else {
				netAccel += _forces[i]; // Will have influence of timeMulti and weight here (ACTUALLY WEIGHT PROBABLY JUST IN FRICTION)
			}
		}
		
		return netAccel;
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
