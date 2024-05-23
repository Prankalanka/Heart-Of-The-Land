// Spawn a random amount (3-6) of randomly sprited (0-5) grass tufts
// At randomised offsets (range of 0 - 45 pixels) of equally divided positions (0-15)

// Can turn everything into a var inside a big function
// Keeping them instance variables for debug purposes

// Generate Amount
tuftAmountMin = 25;
tuftAmountMax = 40;
tuftAmount = irandom_range(tuftAmountMin, tuftAmountMax);

// Generate Sprite Per Tuft
tuftSpriteMin = 0;
tuftSpriteMax = 5;
tuftSprites = [];

for (var i = 0; i < tuftAmount; i++) {
	tuftSprites[i] = irandom_range(tuftSpriteMin, tuftSpriteMax);
} 

// Generate Equal Offsets (hopefully maths right)
tuftPosAmount = 15;
tuftPosAmount += (tuftAmountMax - tuftPosAmount);
tuftPosBoundsPercentage = 20;
tuftPosBoundsFraction = 100/tuftPosBoundsPercentage;
spriteWidth = sprite_get_width(sprite_index);

tuftPosMin = spriteWidth/tuftPosBoundsFraction;
tuftPosMax = spriteWidth - tuftPosMin;

tuftBoundsWidth = spriteWidth - tuftPosMin * 2;

tuftPosEqual = [];

for (var i = 0; i < tuftPosAmount; i++) {
	tuftPosEqual[i] = tuftPosMin + tuftBoundsWidth/tuftPosAmount * i; 
}

for (var i = 0; i < tuftPosAmount - tuftAmount; i++) {
	var _index = irandom_range(0, array_length(tuftPosEqual));
	array_delete(tuftPosEqual, _index, 1); // Hopefully stitches array back together
	//show_debug_message(tuftPosEqual);
}

// Generate Randomised Offset
offsetClamp = 0;
offsetMin = -45;
offsetMax = 45;
tuftPosOffsets = [];

tuftWidth = sprite_get_width(spr_grass_tuft);
spriteHeight = sprite_get_height(sprite_index);
tuftHeight = sprite_get_height(spr_grass_tuft);

bugPosArray = [];

for (var i = 0; i < tuftAmount; i++) {
	var _randOffset = 0;
	if i == 0 {
		_randOffset = random_range(offsetClamp, offsetMax);
	}
	else if i == tuftAmount-1 {
		_randOffset = random_range(offsetMin, offsetClamp);
	}
	else {
		_randOffset = random_range(offsetMin, offsetMax);
	}
	
	tuftPosOffsets[i] = tuftPosEqual[i] + _randOffset;
	
	var _overlapDist = 2;
	var _xPos = x - spriteWidth/2 + tuftPosOffsets[i];
	var _yPos = y - spriteHeight/2 - tuftHeight/2;
	
	var _overlapTufts = ds_list_create();
	
	var _overlapTuftAmt = collision_rectangle_list(_xPos - _overlapDist, _yPos + _overlapDist, _xPos + _overlapDist, _yPos - _overlapDist, obj_grass_tuft, false, true, _overlapTufts, true);
	if ds_list_size(_overlapTufts) != 0 {
		if i == 0 {
			_randOffset = random_range(offsetClamp, offsetMax);
		}
		else if i == tuftAmount-1 {
			_randOffset = random_range(offsetMin, offsetClamp);
		}
		else {
			_randOffset = random_range(offsetMin, offsetMax);
		}
		
		tuftPosOffsets[i] = tuftPosEqual[i] + _randOffset;
		ds_list_destroy(_overlapTufts);
		_overlapTufts = ds_list_create();
		_overlapTuftAmt = collision_rectangle_list(_xPos - _overlapDist, _yPos + _overlapDist, _xPos + _overlapDist, _yPos - _overlapDist, obj_grass_tuft, false, true, _overlapTufts, true);
		
		if  ds_list_size(_overlapTufts) != 0 {
			array_delete(tuftPosOffsets, i, 1);
			array_delete(tuftSprites, i, 1);
			array_delete(tuftPosEqual, i, 1);
			tuftAmount = array_length(tuftPosOffsets);
		}
		else {
			instance_create_layer(x - spriteWidth/2 + tuftPosOffsets[i], y - spriteHeight/2 - tuftHeight/2, "Foliage_Ground_Stuff", obj_grass_tuft,
			{
				image_index : tuftSprites[i],
			})
			show_debug_message([tuftPosOffsets, tuftAmount, tuftSprites]);
		}
	}
	else {
		bugPosArray[i] = [_xPos,_yPos];
		instance_create_layer(x - spriteWidth/2 + tuftPosOffsets[i], y - spriteHeight/2 - tuftHeight/2, "Foliage_Ground_Stuff", obj_grass_tuft,
		{
			image_index : tuftSprites[i],
		})
		show_debug_message([tuftPosOffsets, tuftAmount, tuftSprites]);
	}
	ds_list_destroy(_overlapTufts);
}