bounds = [
bbox_left,
bbox_top,
bbox_right,
bbox_bottom,
];

if image_index == 0 { 
	bounds[0] = -infinity;
}
else if image_index == 1 { 
	bounds[2] = infinity;
}
else if image_index == 2 {
	bounds[0] = -infinity;
	bounds[2] = infinity;
}
