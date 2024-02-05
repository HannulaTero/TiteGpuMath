/// @desc VISUALIZE
var _size = 256;
var _step = _size + 16;
matPos.Draw(64 + _step * 0, 64, {
	width: 256,
	height: 256,
	normalize: true,
	rangeMin: 0.0,
	rangeMax: room_width,
});
matSpd.Draw(64 + _step * 1, 64, {
	width: 256,
	height: 256,
	normalize: true,
	rangeMin: -8.0,
	rangeMax: +8.0,
});

