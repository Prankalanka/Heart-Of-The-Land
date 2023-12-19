if keyboard_check(ord("P")) {
	projectileState.dangle -= 5;
	projectileState.angle = degtorad(projectileState.dangle);
	show_debug_message(projectileState.angle);
}
else if keyboard_check(ord("O")) {
	//show_debug_message("huh");
	projectileState.initVel += 5;
	show_debug_message(projectileState.initVel);
}
stateMachine.updLogic();

//DEBUGGING
//show_debug_message([xVel, yVel]);
//stateMachine.showNames();







