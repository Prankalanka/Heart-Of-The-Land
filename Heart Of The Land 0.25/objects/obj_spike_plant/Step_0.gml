frame--;

if frame = 0 {
	frame = framesPerChange;
	if reversed {
		image_index--
	}
	else {
		image_index++
	}
	
	if image_index == 10
	{
		reversed = true;
	}
	if image_index == 0
	{
		reversed = false;
	}
}
