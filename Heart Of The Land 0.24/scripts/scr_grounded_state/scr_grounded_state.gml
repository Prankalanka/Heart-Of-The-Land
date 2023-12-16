/// Super class for all grounded states.
function GroundedState(_id, _animName) : EntityState(_id, _animName) constructor
{
	// Store super class' enter function before redefining it
	// Can't call it the same name cuz errors, so it's specific for each super class
	static stateSEnter = sEnter;
	xInputDir = 0;
	
	static updLogic = function() {
		// Update xInput
		xInputDir = entity.inputHandler.xInputDir;
	}
	
	static sEnter = function(_data = undefined) {
		stateSEnter();
		// You don't keep acceleration when you collide with an object
		yVel = 0;
	}
	
	static checkReg1 =  function() {
		
		if entity.autonomous {
			// Changes to Dash State if there's input
			if entity.inputHandler.dashInput != 0 {
				stateMachine.changeState(entity.dashState, 1);
			}
		}
		if entity.inputHandler.projectileInput {
			stateMachine.changeState(entity.projectileState, 1, [0.1, 300]);
		}
	}
	
	static checkReg2 =  function() {
		entity.yVel = 0; // So InAir knows we've been grounded, also perfomance
		
		if entity.autonomous {
			// Changes to InAir state if nothing is below us
			if  !(entity.isBelow) {
				stateMachine.changeState(entity.inAirState, 2);
			} // Changes to Jump State if there's input
			else if entity.inputHandler.jumpInput and !entity.isAbove {
				stateMachine.changeState(entity.jumpState, 2);
			}
		}
		if entity.inputHandler.projectileInput {
			stateMachine.changeState(entity.projectileState, 2, [0.1, 300]);
		}
	}
	
}


/// Changes to move state if xInput
function IdleState(_id, _animName) : GroundedState(_id, _animName) constructor
{
	static name = "Idle";
	static num = 0;
	static groundedUpdLogic = updLogic;
	static groundedCheckReg1 = checkReg1;
	static groundedCheckReg2 = checkReg2;
	
	static updLogic = function() {
		if entity.autonomous {
			groundedUpdLogic();  // Update xInput and change to InAir state
		}
		
		if inRegion[1] {
			if entity.autonomous {
				// Go to move state if input
				if xInputDir != 0 or entity.xVel != 0 {
					stateMachine.changeState(entity.walkState, 1);
				}
			}
			groundedCheckReg1();
		}
		if inRegion[2] {
			if entity.autonomous {
				// Go to move state if input
				if xInputDir != 0 or entity.xVel != 0 {
					stateMachine.changeState(entity.walkState, 2);
				}
			}
			groundedCheckReg2();
		}
	}
}


/// Changes to IdleState if no xInput and xVel is 0
function WalkState(_id, _animName) : GroundedState(_id, _animName) constructor
{
	static name = "Move";
	static num = 1;
	static groundedUpdLogic = updLogic;
	static groundedSEnter = sEnter;
	static groundedCheckReg1 = checkReg1;
	static groundedCheckReg2 = checkReg2;
	xVel = entity.xVel;
	xVelClamp = entity.xVelClamp;
	decel = entity.decel;
	
	static updLogic = function () {
		groundedUpdLogic(); // Update xInput 
		xVel = entity.xVel;
		
		if inRegion[2] { 
			
			// Check change to Idle State
			if xInputDir == 0 and xVel == 0 {
				stateMachine.changeState(entity.idleState, 2);
			}
			groundedCheckReg2();
		} 
		
		if inRegion[1] {
	
			// Update xVel and X
			if abs(xVel) < xVelClamp {
				entity.updWalk(xInputDir); 
			}
			else {
				entity.updXVel();
			}
			
			// Change to idle animation via argument in updX if we're not pressing anything
			with entity {
				if inputHandler.xInputDir == 0 and abs(xVel) < 1 and walkState.inRegion[2] { // Should add a buffer to prevent flicking to idle anim when switching directions
					if xVel	!= 0 {
						updX(sign(xVel) * 2);
					}
					else {
						var _dir = 0;
						
						if lastDirFaced == 0 {
							_dir = 2;
						}
						else {
							_dir = -2;
						}
						updX(_dir);
					}
					// should change the way we do this, could just do it in here
				} 
				else {
					updX(inputHandler.xInputDir);
				}
				// Scales animation speed with our current speed
				image_speed = 0.5 + 0.5 * abs(xVel/xVelClamp);
			}
			
			// Go to idle state if no input and no velocity
			if xInputDir == 0 and xVel == 0 {
				stateMachine.changeState(entity.idleState, 1);
			}
			groundedCheckReg1();
		}
		
	}
	
	static sEnter = function(_data = undefined) {
		groundedSEnter();
		entity.image_index = 0;  // Start at first walk frame
	}
	
	static sExit = function() {
		entity.image_speed = 1; // Stop scaling based on horizontal speed
	}
}

/*
function GroundMotionState(_id, _animName) : GroundedState(_id, _animName) constructor {
	static name = "Ground Motion";
	static num = 6;
	static groundedUpdLogic = updLogic;
	decel = 0.87;
	walkVarA = entity.walkVarA;
	walkVarB = entity.walkVarB;
	fakeMaxSpeed = entity.fakeMaxSpeed;
	
	static updLogic = function() {
		xVel = entity.xVel;
		var _nextXVel =  xVel * decel;
	
		if abs(_nextXVel) >= entity.xVelClamp {
			entity.xVel = _nextXVel;
			with entity {updX(sign(xVel));}
		}
		// If we're going below the clamp then switch to walk acceleration
		else {
			groundedUpdLogic(); // Get xInputDir
			
			// Calculate walkFrame based on current xVel
			var _nextWalkFrame = (round(power(((xVel * power(walkVarA, walkVarB)) / (fakeMaxSpeed - xVel)), (1/walkVarB))));
			
			// If we aren't holding anything, decrease the abs value of walkFrame by four, up to 0
			if xInputDir == 0 {
				// Clamp to 0 or do normal equation
				if sign( _nextWalkFrame) != _nextWalkFrame + 2.5 * sign(xVel) * -1 {
					entity.walkFrame = 0;
				}
				else {
					_nextWalkFrame = _nextWalkFrame + 2.5 * sign(xVel) * -1;
				}
			}
			// If we are holding a different direction thane we're going, decrease abs value of walkFrame by 2.5
			else if xInputDir != sign(_nextWalkFrame + sign(xVel)) {
				_nextWalkFrame = _nextWalkFrame + 2.5 * sign(xVel) * -1;
			}
			// Default
			else {
				_nextWalkFrame = _nextWalkFrame + xInputDir;
			}
			
			// Clamp walkFrame
			if abs(_nextWalkFrame) < 25 {
				entity.walkFrame = _nextWalkFrame;
			} 
			else {
				_nextWalkFrame = 25 // Or xVel will end up bigger because we use this var in the calculation			
			}
			
			//show_debug_message(["aaaaaaaaaaaaaaa", _nextWalkFrame]);
			// Can rely on previous xVel value because we dont want to decelerate to the opposite sign of our starting velocity
			entity.xVel = ((fakeMaxSpeed * power(_nextWalkFrame, walkVarB)) / (power(walkVarA, walkVarB) + power(_nextWalkFrame, walkVarB))) * sign(xVel);
			entity.walkFrame = _nextWalkFrame * sign(xVel);
			with entity {updX(sign(xVel));}
			stateMachine.changeState(entity.walkState, 1);
		}
	}
	checkReg1();
}
*/