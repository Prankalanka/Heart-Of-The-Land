/// @description Insert description here
// You can write your code in this editor
background_map = ds_map_create();

// Back layer (except for the out of focus trees
background_map[? layer_get_id("Back_Sky")] = 0.3;
background_map[? layer_get_id("Back_Cloud_1")] = 0.2;
background_map[? layer_get_id("Back_Cloud_2")] = 0.22;
background_map[? layer_get_id("Back_Cloud_3")] = 0.28;
background_map[? layer_get_id("Back_Cloud_4")] = 0.24;
background_map[? layer_get_id("Back_Cloud_5")] = 0.26;
background_map[? layer_get_id("Back_Out_Of_Focus_Trees")] = 0.2;

background_map[? layer_get_id("Mid_Fog")] = 0.15;
background_map[? layer_get_id("Mid_Land")] = 0.1;

background_map[? layer_get_id("Top_Land")] = 0;









