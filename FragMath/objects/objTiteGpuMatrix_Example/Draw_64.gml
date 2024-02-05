/// @desc INFORMATION

var _x = 32;
var _y = room_height - 256;
var _b = 32;
var _i = 0;
draw_text_transformed(_x, _y + _b * _i++, "Press Backspace to Randomize.", 2, 2, 0);
draw_text_transformed(_x, _y + _b * _i++, "Press Enter to Update.", 2, 2, 0);
draw_text_transformed(_x, _y + _b * _i++, "Press Up/Down to resize matrices.", 2, 2, 0);
draw_text_transformed(_x, _y + _b * _i++, $" - Sizes: [{dimension}, {dimension}]", 2, 2, 0);
if (dimension > 512)
{
	draw_text_transformed(_x, _y + _b * _i++, "WARNING!", 2, 2, 0);
	draw_text_transformed(_x, _y + _b * _i++, " -> Hacky particle rendering is slow!", 2, 2, 0);
}
