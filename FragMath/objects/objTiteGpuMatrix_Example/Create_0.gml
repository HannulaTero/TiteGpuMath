/// @desc
show_debug_overlay(true, true);

// Allow resizing for more.
dimension = 64;

// The data.
var _format = (surface_format_is_supported(surface_rgba32float))
	? surface_rgba32float
	: (surface_format_is_supported(surface_rgba16float)
		? surface_rgba16float
		: surface_rgba8unorm
	);
		
matPos = new TiteGpuMatrix(dimension, dimension, { 
	name: "Current Position",
	format: _format
});

matSpd = new TiteGpuMatrix(dimension, dimension, { 
	name: "Previous Position",
	format: _format
});

// For visualization. 
vertexBuffer = undefined;
vertex_format_begin();
vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);
vertexFormat = vertex_format_end();