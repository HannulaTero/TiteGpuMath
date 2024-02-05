/// @desc VISUALIZE SURFACES
var _x = 128;
var _y = 128;
var _size = 256;
var _step = _size + 16;

matPos.Draw(_x, _y, {
	width: 256,
	height: 256,
	normalize: true,
	rangeMin: 0.0,
	rangeMax: room_width,
	background: true,
	outline: true
});

_x += _step;
matSpd.Draw(_x, _y, {
	width: 256,
	height: 256,
	normalize: true,
	rangeMin: -8.0,
	rangeMax: +8.0,
	background: true,
	outline: true,
});

