
function InAirState(_id, _animName) : EntityState(_id, _animName) constructor {
	static name = "InAir";
	static num = 2;
	static stateSEnter = sEnter;
	
	static updLogic = function() {
		
		// Update yVel and Y
		entity.updYVel(sign(entity.yVel));
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
		// ONLY NEED TO LOOK OUT FOR TRANSITIONS IN ITS REGION, SO NO DASH CHECKING
		// Change to idle or move state depending on xInput and xVel
		if entity.isBelow {
			if entity.inputHandler.xInputDir == 0 and entity.xVel == 0 {
				stateMachine.changeState(entity.idleState, 2);
			}
			else {
				stateMachine.changeState(entity.walkState, 2);
			}
		}
	}
	
	static sEnter = function() {
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
