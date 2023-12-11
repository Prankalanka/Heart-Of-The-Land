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
	
	static sEnter = function() {
		stateSEnter();
		// You don't keep acceleration when you collide with an object
		yVel = 0;
	}
	
	static checkReg1 =  function() {
		// Changes to Dash State if there's input
		if entity.inputHandler.dashInput != 0 {
			stateMachine.changeState(entity.dashState, 1);
		}
	}
	
	static checkReg2 =  function() {
		entity.yVel = 0; // So InAir knows we've been grounded, also perfomance
		
		// Changes to InAir state if nothing is below us
		if  !(entity.isBelow) {
			stateMachine.changeState(entity.inAirState, 2);
		} // Changes to Jump State if there's input
		else if entity.inputHandler.jumpInput and !entity.isAbove {
			stateMachine.changeState(entity.jumpState, 2);
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
		groundedUpdLogic();  // Update xInput and change to InAir state
		
		if inRegion[1] {
			// Go to move state if input
			if xInputDir != 0 or entity.xVel != 0 {
				stateMachine.changeState(entity.moveState, 1);
				show_debug_message(entity.xVel);
			}
			groundedCheckReg1();
		}
		if inRegion[2] {
			// Go to move state if input
			if xInputDir != 0 or entity.xVel != 0 {
				stateMachine.changeState(entity.moveState, 2);
			}
			groundedCheckReg2();
		}
	}
}


/// Changes to IdleState if no xInput and xVel is 0
function MoveState(_id, _animName) : GroundedState(_id, _animName) constructor
{
	static name = "Move";
	static num = 1;
	static groundedUpdLogic = updLogic;
	static groundedSEnter = sEnter;
	static groundedCheckReg1 = checkReg1;
	static groundedCheckReg2 = checkReg2;
	xVel = entity.xVel;
	
	static updLogic = function () {
		groundedUpdLogic(); // Update xInput 
		xVel = entity.xVel;
		
		
		if inRegion[2] { // This is first because of shouldChangeToIdleAnim
			
			// Check change to Idle State
			if xInputDir == 0 and xVel == 0 {
				stateMachine.changeState(entity.idleState, 2);
			}
			groundedCheckReg2();
		} 
		
		if inRegion[1] {
			
			// Update xVel and X
			entity.walkUpd(xInputDir); 
			
			// Change to idle animation via argument in updX if we're not pressing anything
			with entity {
				if inputHandler.xInputDir == 0 and abs(xVel) < 1 and moveState.inRegion[2] { // Should add a buffer to prevent flicking to idle anim when switching directions
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
	
	static sEnter = function() {
		groundedSEnter();
		entity.image_index = 0;  // Start at first walk frame
	}
	
	static sExit = function() {
		entity.image_speed = 1; // Stop scaling based on horizontal speed
	}
}
