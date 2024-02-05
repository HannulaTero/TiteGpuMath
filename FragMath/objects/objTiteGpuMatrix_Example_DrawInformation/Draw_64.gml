/// @desc DRAW TEXT INFORMATION

// Get size informstion
var _text = text;
with(objTiteGpuMatrix_Example)
{
	_text = $"Matrix size: [{dimension}, {dimension}]\n{_text}";
}

// Draw the text
var _x = 32;
var _y = room_height - 32;
var _height = string_height(_text);
var _scale = 1.25;
draw_set_halign(fa_left);
draw_set_valign(fa_bottom);
draw_text_transformed(_x, _y, _text, _scale, _scale, 0);
