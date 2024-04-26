/// @description Insert description here
// You can write your code in this editor


draw_self();

if activeStates[0] == states[SH.hold] {
	states[SH.hold].drawPath();
	draw_circle_color(states[SH.hold].initMPos[0], states[SH.hold].initMPos[1], 64, c_red, c_orange, false);
}

var _extBox = [bbox_left, bbox_top, bbox_right, bbox_bottom];// Extend left, right and top sides by a quarter of width or height
 var _dirFacing = (persistVar.indexFacing == 0)? 1 : -1;
 // Reduce the hitbox in the opposite direction we're facing
 if _dirFacing = 1 {
	_extBox = [bbox_left + sprite_width/8, bbox_top, bbox_right, bbox_bottom];
}
else {
	_extBox = [bbox_left, bbox_top, bbox_right - sprite_width/8, bbox_bottom];
}
	 
draw_rectangle(_extBox[0], _extBox[1], _extBox[2], _extBox[3], true);






