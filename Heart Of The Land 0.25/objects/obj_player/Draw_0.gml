/// @description Insert description here
// You can write your code in this editor


draw_self();

if activeStates[0] == states[SH.HOLD] {
	states[SH.HOLD].drawPath();
	draw_circle_color(states[SH.HOLD].initMPos[0], states[SH.HOLD].initMPos[1], 64, c_red, c_orange, false);
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

var _yCam = camera_get_view_y(view_camera[0]);
var _xCam = camera_get_view_x(view_camera[0]);


//draw_line(_xCam + xMidOffset, _yCam + yMidOffset + yMaxPlyrCamOffset, _xCam + xMidOffset, _yCam + yMidOffset - yMaxPlyrCamOffset);




