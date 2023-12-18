
function InAirState(_id, _animName) : EntityState(_id, _animName) constructor {
	static name = "InAir";
	static num = STATEHIERARCHY.inAir;
	static stateSEnter = sEnter;
	
	static updLogic = function() {
		
		// Update yVel and Y
		entity.updYVel();
		with(entity){
			// Change anim if we're ascending
			if(sign(yVel) == -1) {
				image_index = 1;
			}
			else {
				image_index = 2;
			}
			updY();
		}
		
		// Update coyote buffer
		entity.updCoyote();
		
		
		// Coyote buffered jump
		if  !entity.isAbove and entity.inputHandler.jumpInput and entity.coyoteBuffer != 0 and entity.inputHandler.spaceReleasedSinceJump{
			stateMachine.changeState(entity.jumpState, 2);
		}
		
		
		//show_debug_message("aaa");
		// ONLY NEED TO LOOK OUT FOR TRANSITIONS IN ITS REGION, SO NO DASH CHECKING
		// Change to idle or move state depending on xInput and xVel
		if entity.isBelow {
			//show_debug_message("hh");
			if entity.inputHandler.xInputDir == 0 and entity.xVel == 0 {
				stateMachine.changeState(entity.idleState, 2);
			}
			else {
				stateMachine.changeState(entity.walkState, 2);
			}
		}
	}
	
	static sEnter = function(_data) {
		// Set animation
		stateSEnter();
		
		// yVel only becomes 0 if we've been grounded, and then transitioned to the inAir state
		// that's when we want to max out coyote
		if entity.yVel == 0{
			entity.coyoteBuffer = entity.coyoteMax;
		}
		else {
			entity.coyoteBuffer = 0;
		}
	}
	
	
}
