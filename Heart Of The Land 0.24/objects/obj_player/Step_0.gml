// If we're dead we shouldn't do anything that frame
checkHp(); // player health state

moveCamera(); // camera object

execPipeLine();

// Idle combat state
if mouse_check_button(mb_left)  and attackCd
{
	attackExec(); // function belonging to attack combat state
}


//DEBUGGING
if  keyboard_check_pressed(ord("V")) {
	show_debug_message(xVelArray);
}
//show_debug_message([
//persistVar.xVel,
//states[SH.walk].walkVel,
//states[SH.walk].walkAccel
//]);

//show_debug_message([
//persistVar.yVel
//]);
//show_debug_message(yVel); 
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
//show_debug_message(inputHandler.climbHeld);