/// @desc DO THE CALCULATIONS

// Set position middle of room, with slight random position
if (keyboard_check(vk_backspace))
{
	matPos.Randomize(room_width/2-64, room_width/2+64);
}

// Update positions and speed.
if (keyboard_check(vk_enter))
|| (keyboard_check_pressed(vk_space))
{
	matPos.Add(matSpd);				// Position update.
	matSpd.Scale(,0.975);			// Friction.
	matSpd.Offset(,[0,0.5,0,0]);	// Gravity.
	//matPos.Clamp(, 0, room_width);
}

// Set random speed
if (keyboard_check(vk_left)) 
{
	matSpd.Randomize(-64.0, +64.0);
}

// Add small randomness to speed
if (keyboard_check(vk_right)) 
{
	matSpd.Cumulative().Randomize(-2.0, +2.0);
}


