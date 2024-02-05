/// @desc CHANGE THE MATRIX SIZES

var _previous = dimension;
if (keyboard_check_pressed(vk_up)) 
	dimension *= 2;

if (keyboard_check_pressed(vk_down)) 
	dimension /= 2;

dimension = clamp(dimension, 16, 2048);

// Update size if changed.
if (_previous != dimension)
{
	matPos.Initialize(dimension, dimension);
	matSpd.Initialize(dimension, dimension);
}