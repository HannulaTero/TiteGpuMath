/// @desc DO THE CALCULATIONS

// Reset particles.
if (keyboard_check(ord("R")))
	Reset();
	
// Test out the LUT
if (keyboard_check(vk_numpad0))
	matSpd.Lut(, lutSin);

// Update positions and speed.
if (keyboard_check(vk_enter)) || (keyboard_check_pressed(vk_space))
{
	matPos.Add(matSpd);		// Position update.
	matSpd.Scale(, 0.995);	// Friction.
	matSpd.Offset(, [0.0, 0.5]); // Gravity.
	matPos.Clamp(, [0, -infinity], [room_width, room_height]);
	
	vm.Execute(@"
		pos += spd;
		spd *= 0.995;
		spd += [0.0, 0.5];
		pos = clamp(pos, 0, room_width);
	");
}

// Add small randomness to position.
if (keyboard_check(vk_left)) 
{
	matPos.Cumulative().Randomize(-2.0, +2.0);
}

// Add small randomness to speed.
if (keyboard_check(vk_right)) 
{
	matSpd.Cumulative().Randomize(-2.0, +2.0);
}


