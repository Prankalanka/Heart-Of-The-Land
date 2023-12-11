/// @description Insert description here
// You can write your code in this editor

yDir = 0;
isBelow =  place_meeting(x, (y + 1), obj_platform);
isAbove = place_meeting(x, (y - 1), obj_platform);
xVel = 0;
 
if x + xVel > xMax 
{
	xVel = -xVel;
}
else if x + xVel < xMin 
{
	xVel = -xVel;
}


if !isBelow and !(yVel < 0)
{
	yDir = 0;
} else {yDir = sign(yVel);}

yVel -= grav;


if abs(x - plyr.x) <= 700
{
	if abs(x - plyr.x) <= 100 and attackCd and abs(plyr.y - y) < 30
	{
		instance_create_layer(x + 100 * xDir, y - 50, "Instances", obj_bite, {
			image_xscale : 1,
			image_yscale : 1,
			fx : 100 * xDir,
			fy : -50,
			entity : id
		});
	} 
	else 
	{
		xDir = sign(plyr.x - x);
		targetX = plyr.x + 2000*xDir;
		xVel = xDir * 4;
	}
	
	/*
	if abs(x - plyr.x) <= 200 and (abs(y) - abs(plyr.y)) >= peak and y >= plyr.y 
	{
		heightFraction = (plyr.y - y)/peak;
	
		// Target where the player is going to be in the time it takes us to reach the player's y pos
		targetX = plyr.x + plyr.xVel * framesToPeak * heightFraction;
		targetY = plyr.y;
	
		xVel = (x - targetX) / framesToPeak;
		yVel = initDiveVel;
	}
	*/
}

if (place_meeting(x + (xVel * 20), y, obj_platform) or !place_meeting(x + (xVel * 20), y + 1, obj_platform)) and isBelow
{

	yVel = initDiveVel;
	yDir = -1;
}

if ( (yDir != 0) and place_meeting(x, y + yVel, obj_platform))
{
	yVel = 0;
	while (!place_meeting(x, y + yDir, obj_platform)) {y += yDir;}
}
else if yDir == 0 and (isBelow or isAbove) {yVel = 0;} 

if (sign(xVel) != 0) and place_meeting(x + xVel, y, obj_platform) {
	// we add the velocity on to the x variable of the object 
	while !place_meeting(x + sign(xVel), y, obj_platform) {x += sign(xVel);}
	xVel = 0;
} else {x += xVel;}


if sign(xVel) == 1 
{
	image_xscale = 0.75;
}
else { image_xscale = -0.75}

x += xVel;
y += yVel;

if place_meeting(x, y, obj_platform) 
{
	var pXLength = 1;
	var nXLength = 1;
	
	var pYLength = 1;
	var nYLength = 1;

	
	while (place_meeting(x + pXLength, y, obj_platform)) { pXLength += 1;}
	while (place_meeting(x - nXLength, y, obj_platform)) { nXLength += 1;}
	while (place_meeting(x, y + pYLength, obj_platform)) { pYLength += 1;}
	while (place_meeting(x, y - nYLength, obj_platform)) { nYLength += 1;}
	
	var smolDirX = min(pXLength, nXLength);
	var smolDirY = min(pYLength, nYLength);
	
	
	if smolDirY == nYLength {
		smolDirY = smolDirY * -1;
	}
	if smolDirX == nXLength {
		smolDirX = smolDirX * -1;
	}
	
	if abs(smolDirX) < abs(smolDirY)
	{
		x += smolDirX;
		//show_debug_message(smolDirX);
	} else {
		y += smolDirY;
		//show_debug_message(smolDirY);
	}
}

//show_debug_message(yVel);