/// @description Insert description here
// You can write your code in this editor


draw_self();

if stateMachine.currentStates[0] == holdState {
	holdState.drawPath();
	draw_circle_color(holdState.initMPos[0], holdState.initMPos[1], 64, c_red, c_orange, false);
}

var _extBox = [bbox_left, bbox_top, bbox_right, bbox_bottom];// Extend left, right and top sides by a quarter of width or height
var _dirFacing = (dirFacing == 0)? 1 : -1;
draw_rectangle(_extBox[0] + sprite_width / 10 * _dirFacing, _extBox[1], _extBox[2] + sprite_width / 10 * _dirFacing, _extBox[3], true);






