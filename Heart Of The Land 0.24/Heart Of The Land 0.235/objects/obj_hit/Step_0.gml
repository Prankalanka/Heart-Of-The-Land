// Keep the hitbox at the player's offset
x = plyr.x + fx;
y = plyr.y + fy;
 
var enemy_hit = ds_list_create(); // Create a ds list to store the id of instances
// Check if there's any enemies within our bounding box, store their ids in the ds list
// and how many there are in enemy_amt
var enemy_amt = instance_place_list(x, y, Enemies, enemy_hit, false); 

// For the enemies hit, take away 20 health if they're not already hit 
// Say they're already hit if they're not
for (var i = 0; i < enemy_amt; i += 1) 
{
	var prev_hit = false;
	
	// Try to find the matching id in the prev_hit list
	// If you do prev_hit = true and the enemy will not take dmg
	// Break out the loop cecause the match has been found
	// Should use enums to compare
	for (var j = 0; j < array_length(enemy_prev_hit); j += 1) 
	{
		if enemy_hit[| i] == enemy_prev_hit[j] {prev_hit = true; break;}
	}
	
	if !prev_hit 
	{
		enemy_hit[| i].hp -= 20;
		enemy_hit[| i].image_blend = c_red;
		enemy_hit[| i].alarm_set(2, 20);
		array_push(enemy_prev_hit, enemy_hit[| i]);
	}
}	

ds_list_destroy(enemy_hit); // Need to garbage collect ds lists






