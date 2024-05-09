if hp <= 0 {
	obj_destroyer.destroy_obj(id);
}

for (var i = 0; i < instance_number(obj_player); ++i;)
{

	if collision_circle(x, y, 200, obj_player, false, true)
	{
		image_angle = point_direction(plyr.x,plyr.y, x, y);

		targetX = (diving)? plyr.x - x: plyr.x - x;
		targetY = (diving)? plyr.y - y : plyr.y - y;
		
		//the distance between the player's y and our y is the peak of the dive
		//how long it takes to get to the peak is around a second (60 frames)
		//how fast we travel along the x axis is decided by how quick we'll reach our peak
		//it should take 60 frames for us to reach the player's x so we just divide the targetX by 60
		peak = targetY;
		framesToPeak = 30
		initDiveVel = (2 * peak) / framesToPeak;
		grav = (2 * peak) / sqr(framesToPeak);
		
		
		yVel = initDiveVel;
		yVel -= grav;
		
		xVel = targetX/framesToPeak;
		
	
		
		x += xVel;
		y += yVel;
	}
	else if collision_circle(x, y,  detect_rad, obj_player, false, true)
	{
		image_angle = point_direction(plyr.x,plyr.y, x, y);
		targetX =  plyr.x - x;
		targetY= plyr.y - y - 50;
		
		var len = sqrt(sqr(targetX) + sqr(targetY));
		
		var speed_x = (targetX/len) * 5;
		var speed_y = (targetY/len) * 5;
		
		x += speed_x;
		y += speed_y;
		
	}
}

if place_meeting(x,y, obj_player) and attack_cd
{
	plyr.hp -= 20;
	plyr.image_blend = c_red;
	plyr.alarm[1] = 20;
	show_debug_message(plyr.hp);
	attack_cd = false;
	alarm[1] = 240;
}

// once the player is within quite a large range, move toward the player's x position and when
// your positions are close enough perform a dive
// a dive involves following a parabola where the player's position (offset it depending on speed)
// is on it, normally the player's position + an offset is the peak
