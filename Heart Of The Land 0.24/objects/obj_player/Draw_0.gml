/// @description Insert description here
// You can write your code in this editor


draw_self();

if stateMachine.currentStates[0] == holdState {
	holdState.drawPath();
	draw_circle_color(holdState.initMPos[0], holdState.initMPos[1], 64, c_red, c_orange, false);
}








