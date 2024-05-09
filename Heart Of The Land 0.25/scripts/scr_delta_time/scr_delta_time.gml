// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

global.targetDelta = 1/60; // The amount of time in milliseconds between the previous frame and current frame at 60 fps
global.actualDelta = delta_time / 1000000; // The time between the previous frame and current frame set to milliseconds from microseconds
// The percentage of how long it actually took to get from the previous frame to the current frame, measured against how long it should regularly take at our fps
global.deltaMultiplier = actualDelta / targetDelta; 

/// FInd the deltaMultiplier of the current frame;
function scr_delta_time(){
	global.actualDelta = delta_time / 1000000;
	global.deltaMultiplier = actualDelta / targetDelta;
}