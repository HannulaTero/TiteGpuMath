/// @desc DO THE CALCULATIONS

// Randomize
if (keyboard_check(vk_backspace))
{
	matPos.Randomize(room_width/2-64, room_width/2+64);
	matSpd.Randomize(-64.0, +64.0);
}

// Update positions and speed.
if (keyboard_check(vk_enter))
|| (keyboard_check_pressed(vk_space))
{
	matPos.Add(matSpd);				// Position update.
	matSpd.Scale(,0.975);			// Friction.
	matSpd.Offset(,[0,0.5,0,0]);	// Gravity.
	matPos.Clamp(, 0, room_width);
}

// Add small randomness to speed
if (keyboard_check(vk_right)) 
{
	matSpd.Randomize(-2.0, +2.0);
}


