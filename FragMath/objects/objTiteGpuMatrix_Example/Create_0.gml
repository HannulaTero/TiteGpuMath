/// @desc
show_debug_overlay(true, true);

// Allow resizing for more.
dimension = 256;


// Get highest supported type for particles.
// Though only with 32float it looks nice, and with 8unorm doesn't even work.
var _format = (surface_format_is_supported(surface_rgba32float))
	? surface_rgba32float
	: (surface_format_is_supported(surface_rgba16float)
		? surface_rgba16float
		: surface_rgba8unorm
	);
		
		
// The matrix data, used for simple particles.
matPos = new TiteGpuMatrix(dimension, dimension, { 
	name: "Position",
	format: _format
});

matSpd = new TiteGpuMatrix(dimension, dimension, { 
	name: "Speed",
	format: _format
});
