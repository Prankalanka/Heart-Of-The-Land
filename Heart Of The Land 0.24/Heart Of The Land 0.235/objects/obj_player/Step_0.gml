// If we're dead we shouldn't do anything
checkHp(); // player health state

moveCamera(); // player camera state

inputHandler.checkInputs();
// Something to decide if we need to switch states
stateMachine.updLogic();

if mouse_check_button(mb_left)  and attackCd
{
	attackExec();
}

//DEBUGGING
//show_debug_message(xVel);
//show_debug_message(sprite_index);
show_debug_message(yVel); 
//show_debug_message(isBelow);
//show_debug_message(yDir);
//show_debug_message(isJumping);
//show_debug_message(spaceReleased);
//show_debug_message(jumpFrame);
//show_debug_message(coyoteBuffer);
//show_debug_message(sprite_index);
//show_debug_message(dashing);
//show_debug_message(dashFrame);
//show_debug_message(dash_buffer[0]);
//show_debug_message("huh");
//show_debug_message(dash_buffer[1]);
//show_debug_message(yDir);
//show_debug_message(magnitude);
//show_debug_message(state);
//show_debug_message(inputHandler.dashInput);