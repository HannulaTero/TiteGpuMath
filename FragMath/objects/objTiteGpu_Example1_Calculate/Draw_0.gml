/// @desc VISUALIZE SURFACES

// Prepare
var _x = 128;
var _y = 128;
var _size = 256;
var _step = _size + 16;
var _filter = gpu_get_tex_filter();

// Draw surfaces.
gpu_set_tex_filter(false);
matPos.Draw(_x, _y, {
	width: _size,
	height: _size,
	normalize: true,
	rangeMin: 0.0,
	rangeMax: room_width,
	background: true,
	outline: true
});

_x += _step;
matSpd.Draw(_x, _y, {
	width: _size,
	height: _size,
	normalize: true,
	rangeMin: -8.0,
	rangeMax: +8.0,
	background: true,
	outline: true,
});
gpu_set_tex_filter(_filter);

