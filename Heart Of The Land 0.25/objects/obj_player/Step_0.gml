// If we're dead we shouldn't do anything that frame
checkHp(); // player health state

execPipeLine();

// Idle combat state
//if mouse_check_button(mb_left)  and attackCd
//{
//	attackExec(); // function belonging to attack combat state
//}

array_push(xVelArray, persistVar.xVel);

//DEBUGGING
if  keyboard_check_pressed(ord("V")) {
	show_debug_message(xVelArray);
}
if  keyboard_check_pressed(ord("G")) {
	x = initX;
	y = initY;
}
//show_debug_message([
//persistVar.xVel,
//states[SH.WALK].walkVel,
//states[SH.WALK].walkAccel,
//states[SH.WALK].accelledThisTurn
//]);

//show_debug_message(
//[persistVar.xVel,
//persistVar.yVel, 
//]
//);
////show_debug_message(yVel); 
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