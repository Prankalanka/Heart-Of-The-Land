/// @description Insert description here
// You can write your code in this editor

x = entity.x + fx;
y = entity.y + fy;

if instance_place(x,y, obj_player) == plyr and !prevHit
{
	plyr.hp -= 20;
	plyr.image_blend = c_red;
	plyr.alarm[1] = 20;
	show_debug_message(plyr.hp);
	entity.attackCd = false;
	entity.alarm[0] = 90;
	prevHit = true;
}
 
