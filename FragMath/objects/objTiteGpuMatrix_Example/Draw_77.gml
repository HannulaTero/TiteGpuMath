/// @desc DO THE CALCULATIONS
if (keyboard_check(vk_backspace))
{
	matPos.Randomize(room_width, room_height);
	matSpd.Randomize(-8.0, +8.0);
}

if (keyboard_check(vk_enter))
|| (keyboard_check_pressed(vk_space))
{
	matPos.Add(matSpd);
	matSpd.Scale(,0.995);
}












