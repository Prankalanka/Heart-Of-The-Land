// Spawn a random amount (3-6) of randomly sprited (0-5) grass tufts
// At randomised offsets (range of 0 - 45 pixels) of equally divided positions (0-15)

// Can turn everything into a var inside a big function
// Keeping them instance variables for debug purposes

// Generate Amount
tuftAmountMin = 60;
tuftAmountMax = 100;
tuftAmount = irandom_range(tuftAmountMin, tuftAmountMax);

// Generate Sprite Per Tuft
tuftSpriteMin = 0;
tuftSpriteMax = 5;
tuftSprites = [];

for (var i = 0; i < tuftAmount; i++) {
	tuftSprites[i] = irandom_range(tuftSpriteMin, tuftSpriteMax);
} 

// Generate Equal Offsets (hopefully maths right)
tuftPosAmount = tuftAmountMax;

tuftPosBoundsPercentage = 40;
tuftPosBoundsFraction = 100/tuftPosBoundsPercentage;
spriteWidth = sprite_get_width(sprite_index);

tuftPosMin = spriteWidth/tuftPosBoundsFraction;
tuftPosMax = spriteWidth - tuftPosMin;

tuftBoundsWidth = spriteWidth - tuftPosMin * 2;

tuftPosEqual = [];

for (var i = 0; i < tuftPosAmount; i++) {
	tuftPosEqual[i] = tuftPosMin + tuftBoundsWidth/tuftPosAmount * i; 
}

for (var i = 0; array_length(tuftSprites) != array_length(tuftPosEqual); i++) {
	var _index = irandom_range(0, array_length(tuftPosEqual));
	array_delete(tuftPosEqual, _index, 1); // Hopefully stitches array back together
	//show_debug_message(tuftPosEqual);
}
show_debug_message([array_length(tuftSprites), array_length(tuftPosEqual), tuftPosAmount, tuftAmount, "CCCCCC"]);

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
	var _minClamp = offsetMin;
	var _maxClamp = offsetMax;
	
	// Ensure tufts are clamped within the range
	if tuftPosEqual[i] + offsetMax > tuftPosMax {
		_maxClamp = tuftPosEqual[i] + offsetMax - tuftPosMax;
	}
	if tuftPosEqual[i] + offsetMin < tuftPosMin {
		_minClamp = tuftPosEqual[i] + offsetMin - tuftPosMin;
	}
	
	_randOffset = random_range(_minClamp, _maxClamp);
	
	tuftPosOffsets[i] = tuftPosEqual[i] + _randOffset;
	
	var _overlapDist = 2;
	var _xPos = x - spriteWidth/2 + tuftPosOffsets[i];
	var _yPos = y - spriteHeight/2 - tuftHeight/2;
	var _overlapTufts = ds_list_create();
	var _overlapTuftAmt = collision_rectangle_list(_xPos - _overlapDist, _yPos + 1, _xPos + _overlapDist, _yPos - 1, obj_grass_tuft, false, true, _overlapTufts, true);
	
	if ds_list_size(_overlapTufts) != 0 {
		// Ensure tufts are clamped within the range
		if tuftPosEqual[i] + offsetMax > tuftPosMax {
			_maxClamp = tuftPosEqual[i] + offsetMax - tuftPosMax;
		}
		if tuftPosEqual[i] + offsetMin < tuftPosMin {
			_minClamp = tuftPosEqual[i] + offsetMin - tuftPosMin;
		}
	
		tuftPosOffsets[i] = tuftPosEqual[i] + _randOffset;
		_xPos = x - spriteWidth/2 + tuftPosOffsets[i];
		
		ds_list_destroy(_overlapTufts);
		_overlapTufts = ds_list_create();
		_overlapTuftAmt = collision_rectangle_list(_xPos - _overlapDist, _yPos + 1, _xPos + _overlapDist, _yPos - 1, obj_grass_tuft, false, true, _overlapTufts, true);
		
		if  ds_list_size(_overlapTufts) != 0 {
			array_delete(tuftPosOffsets, i, 1);
			array_delete(tuftSprites, i, 1);
			array_delete(tuftPosEqual, i, 1);
			tuftAmount = array_length(tuftPosOffsets);
			show_debug_message([array_length(tuftSprites), array_length(tuftPosEqual), array_length(tuftPosOffsets), "AAAAAAAA"]);
		}
		else {
			instance_create_layer(x - spriteWidth/2 + tuftPosOffsets[i], y - spriteHeight/2 - tuftHeight/2, "Foliage_Ground_Stuff", obj_grass_tuft,
			{
				image_index : tuftSprites[i],
			})
			show_debug_message([array_length(tuftSprites), array_length(tuftPosEqual), array_length(tuftPosOffsets), "BBBBBBB"]);
		}
	}
	else {
		instance_create_layer(x - spriteWidth/2 + tuftPosOffsets[i], y - spriteHeight/2 - tuftHeight/2, "Foliage_Ground_Stuff", obj_grass_tuft,
		{
			image_index : tuftSprites[i],
		})
		show_debug_message([array_length(tuftSprites), array_length(tuftPosEqual), array_length(tuftPosOffsets)]);
	}
	ds_list_destroy(_overlapTufts);
}