if keyboard_check(ord("P")) {
	projectileState.dangle -= 5;
	projectileState.angle = degtorad(projectileState.dangle);
}
else if keyboard_check(ord("O")) {
	//show_debug_message("huh");
	projectileState.dangle += 5;
	projectileState.angle = degtorad(projectileState.dangle);
}
stateMachine.updLogic();

//DEBUGGING
//show_debug_message([xVel, yVel]);
//stateMachine.showNames();







