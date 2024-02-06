
/// @func	tite_draw_matrix(_mat, _x, _y, _params);
/// @desc	Draws matrix with given parameters.
/// @param	{Struct.TiteData} _mat
/// @param	{Real}		_x
/// @param	{Real}		_y
/// @param	{Struct}	_params	[Optional]
function tite_draw_matrix(_mat, _x=0, _y=0, _params={}) 
{
	// Get the uniforms.
	tite_forceinline;
	static __shader = tite_shd_visualize;
	static __uniFactor = shader_get_uniform(__shader, "uniFactor");
		
	// Get parameters for drawing.
	var _w = _params[$ "width"] ?? self.size[0];
	var _h = _params[$ "height"] ?? self.size[1];
		_w *= _params[$ "xscale"] ?? 1.0;
		_h *= _params[$ "yscale"] ?? 1.0;
	var _halign = _params[$ "halign"] ?? 0.0;
	var _valign = _params[$ "valign"] ?? 0.0;
		_x -= _w * _halign;
		_y -= _h * _valign;
			
	// Whether draw background.
	if (struct_exists(_params, "background"))
	{
		var _c = c_black;
		draw_rectangle_color(_x, _y, _x+_w, _y+_h, _c,_c,_c,_c, false);
	}
		
	// Whether remap values into. Useful for visualizing float textures.
	if (struct_exists(_params, "normalize"))
	{
		var _min = _params[$ "rangeMin"] ?? 0;
		var _max = _params[$ "rangeMax"] ?? 1;
		shader_set(__shader);
		shader_set_uniform_f(__uniFactor, _min, _max);
		draw_surface_stretched(_mat.Surface(), _x, _y, _w, _h);
		shader_reset();
	} 
	else 
	{
		draw_surface_stretched(_mat.Surface(), _x, _y, _w, _h);
	}
		
	// Whether draw outline.
	if (struct_exists(_params, "outline"))
	{
		var _c = c_white;
		draw_rectangle_color(_x, _y, _x+_w, _y+_h, _c,_c,_c,_c, true);
	}
	return self;
}



