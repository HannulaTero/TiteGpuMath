/// @desc DO THE CALCULATIONS

// Set position middle of room, with slight random position
if (keyboard_check(ord("R")))
{
	matPos.Randomize(room_width/2-64, room_width/2+64);
	matSpd.Randomize(-16.0, +16.0);
	matPos.Cumulative().Randomize(-8.0, +8.0);
	matSpd.Cumulative().Randomize(-8.0, +8.0);
	matSpd.Offset(,[0.0, -12.0, 0.0, 0.0]);
}

// Update positions and speed.
if (keyboard_check(vk_enter))
|| (keyboard_check_pressed(vk_space))
{
	matPos.Add(matSpd);		// Position update.
	matSpd.Scale(,0.995);	// Friction.
	matSpd.Offset(,[0.0, 0.5, 0.0, 0.0]); // Gravity.
	//matPos.Clamp(, 0, room_width);
}

// Add small randomness to speed
if (keyboard_check(vk_left)) 
{
	matPos.Cumulative().Randomize(-2.0, +2.0);
}

if (keyboard_check(vk_right)) 
{
	matSpd.Cumulative().Randomize(-2.0, +2.0);
}


