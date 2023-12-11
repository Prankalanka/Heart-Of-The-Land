/// @description Insert description here
// You can write your code in this editor
detect_rad = 600;

hp = 50;
attack = 25;
attack_cd = true;

targetX = 1;
targetY = 1;

xVel = 0;
yVel = 0;

diving = false;
frames_dove = 180;

peak = targetY;
framesToPeak = 60
initDiveVel = (2 * peak) / framesToPeak;
grav = (2 * peak) / sqr(framesToPeak);



