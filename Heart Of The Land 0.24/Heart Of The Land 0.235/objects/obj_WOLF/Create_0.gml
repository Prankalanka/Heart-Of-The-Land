/// @description Insert description here
// You can write your code in this editor

range = 1000;
xMid = x;
xMin = x - range;
xMax = x + range;

targetX = x + 10;
targetY = 0;

xVel = 6;
yVel = 0;

xDir = 0;
yDir = 0;

isBelow =  place_meeting(x, (y + 1), obj_platform);
isAbove = place_meeting(x, (y - 1), obj_platform);

peak = -150;
framesToPeak = 20
initDiveVel = (2 * peak) / framesToPeak;
grav = (2 * peak) / sqr(framesToPeak);

attackCd = true;