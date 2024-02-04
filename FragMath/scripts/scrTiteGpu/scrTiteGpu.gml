
#macro tite_gpu_forceinline gml_pragma("forceinline")


// Helper global variables.
global.tite_gpu = {}; 
global.tite_gpu.baseTexture = undefined; // Special case for texA (gm_BaseTexture)
global.tite_gpu.previousShader = -1; // Stores so it can be return after calculations are done.


/// @func	tite_gpu_begin();
/// @desc	Changes gpu states to more suitable for calculations
function tite_gpu_begin()
{	
	tite_gpu_forceinline;
	gpu_push_state();
	gpu_set_blendmode_ext(bm_one, bm_zero);
	gpu_set_tex_filter(false);
	gpu_set_tex_repeat(false);
	gpu_set_alphatestenable(false);
	gpu_set_blendenable(false);
}


/// @func	tite_gpu_end();
/// @desc	Returns previous gpu state.
function tite_gpu_end()
{
	tite_gpu_forceinline;
	gpu_pop_state();
	if (global.tite_gpu.previousShader != -1)
	{
		shader_set(global.tite_gpu.previousShader);
	} else {
		shader_reset();
	}
}


/// @func	tite_gpu_shader(_shader);
/// @desc	Select tite operation.
/// @param	{Asset.GMShader} _shader
function tite_gpu_shader(_shader) 
{
	tite_gpu_forceinline;
	global.tite_gpu.previousShader = shader_current();
	shader_set(_shader);
}


/// @func	tite_gpu_set_additive(_additive);
/// @desc	Whether results are "set" or "add" to destination.
/// @param	{Bool} _additive
function tite_gpu_set_additive(_additive=true) 
{
	tite_gpu_forceinline;
	if (_additive) 
	{
		gpu_set_blendenable(true);
		gpu_set_blendmode_ext(bm_one, bm_one);
	} else {
		gpu_set_blendenable(false);
		gpu_set_blendmode_ext(bm_one, bm_zero);
	}
}


/// @func	tite_gpu_set_repetive(_repetive);
/// @desc	Whether texture repeats.
/// @param	{Bool} _repetive
function tite_gpu_set_repetive(_repetive=true)
{
	tite_gpu_forceinline;
	gpu_set_tex_repeat(_repetive);
}


/// @func	tite_gpu_set_interpolate(_interpolate);
/// @desc	Whether texture values are interpolated.
/// @param	{Bool} _interpolate
function tite_gpu_set_interpolate(_interpolate=true) 
{
	tite_gpu_forceinline;
	gpu_set_tex_filter(_interpolate);
}


/// @func	tite_gpu_floatN(_name, _array);
/// @desc	Set shader uniforms with given name.
/// @param	{String}		_name
/// @param	{Array<Real>}	_array
function tite_gpu_floatN(_name, _array)
{
	tite_gpu_forceinline;
	var _shader = shader_current();
	var _uniform = shader_get_uniform(_shader, _name);
	shader_set_uniform_f_array(_uniform, _array);
}


/// @func	tite_gpu_float1(_name, _x);
/// @desc	Set shader uniforms with given name.
/// @param	{String}	_name
/// @param	{Real}		_x
function tite_gpu_float1(_name, _x)
{
	tite_gpu_forceinline;
	var _shader = shader_current();
	var _uniform = shader_get_uniform(_shader, _name);
	shader_set_uniform_f(_uniform, _x);
}


/// @func	tite_gpu_float2(_name, _x, _y);
/// @desc	Set shader uniforms with given name.
/// @param	{String}	_name
/// @param	{Real}		_x
/// @param	{Real}		_y
function tite_gpu_float2(_name, _x, _y)
{
	tite_gpu_forceinline;
	var _shader = shader_current();
	var _uniform = shader_get_uniform(_shader, _name);
	shader_set_uniform_f(_uniform, _x, _y);
}


/// @func	tite_gpu_float3(_name, _x, _y, _z);
/// @desc	Set shader uniforms with given name.
/// @param	{String}	_name
/// @param	{Real}		_x
/// @param	{Real}		_y
/// @param	{Real}		_z
function tite_gpu_float3(_name, _x, _y, _z)
{
	tite_gpu_forceinline;
	var _shader = shader_current();
	var _uniform = shader_get_uniform(_shader, _name);
	shader_set_uniform_f(_uniform, _x, _y, _z);
}


/// @func	tite_gpu_float4(_name, _x, _y, _z, W);
/// @desc	Set shader uniforms with given name.
/// @param	{String}	_name
/// @param	{Real}		_x
/// @param	{Real}		_y
/// @param	{Real}		_z
/// @param	{Real}		_w
function tite_gpu_float4(_name, _x, _y, _z, _w)
{
	tite_gpu_forceinline;
	var _shader = shader_current();
	var _uniform = shader_get_uniform(_shader, _name);
	shader_set_uniform_f(_uniform, _x, _y, _z, _w);
}


/// @func	tite_gpu_sample(_name, _src);
/// @desc	Set matrix as texture sampler to be as input.
/// @param	{String}				_name
/// @param	{Struct.TiteGpuMatrix}	_src
function tite_gpu_sample(_name, _src)
{
	// Note! There is special case for texA, as it is gm_BaseTexture.
	// This way you can define this sampler like others.
	tite_gpu_forceinline;
	if (_name == "texA")
	{
		global.tite_gpu.BaseTexture = _src;
		return self;
	}
		
	// Define other, like texB, as sampler.
	var _shader = shader_current();
	var _sampler = shader_get_sampler_index(_shader, _name);
	texture_set_stage(_sampler, _src.Texture());
}


/// @func	tite_gpu_target(_src);
/// @desc	Set matrix as destination for calculations
/// @param	{Struct.TiteGpuMatrix}	_src
function tite_gpu_target(_src)
{
	tite_gpu_forceinline;
	surface_set_target(_src.Surface());
}


/// @func	tite_gpu_finish();
/// @desc	Rendering to current target is finished.
function tite_gpu_finish()
{
	tite_gpu_forceinline;
	surface_reset_target();
}
	
	
/// @func	tite_gpu_render();
/// @desc	Do the calculation, updates whole target.
function tite_gpu_render()
{
	tite_gpu_forceinline;
	var _target = surface_get_target();
	var _w = surface_get_width(_target);
	var _h = surface_get_height(_target);
		
	// Check whether "texA" has been defined.
	if (global.tite_gpu.BaseTexture != undefined)
	{
		var _texA = global.tite_gpu.BaseTexture.Surface();
		draw_surface_stretched(_texA, 0, 0, _w, _h);
	} else {
		// Add bit padding, as primitives might draw differently on different machines.
		draw_rectangle(-1, -1, _w+1, _h+1, false);
	}
}
	
/// @func	tite_gpu_inplace(_func, _args);
/// @desc	Doing calculations when output should also be an input. Assumes first argument is target. 
/// @param	{Function}		_func	
/// @param	{Array<Any>}	_args	
function tite_gpu_inplace(_func, _args)
{
	// Render source and destination can't be same.
	// Therefore temporary target is created, and then results are copied over.
	tite_gpu_forceinline;
	var _out = _args[0];
	_args[0] = _out.Clone();
	script_execute_ext(_func, _args);
	// feather ignore GM2023
	surface_copy(_out.Surface(), 0, 0, _args[0].Surface());
	_args[0].Free();
	_args[0] = _out;
	return _out;
}


/// @func	tite_gpu_match_piecewise(_lhs, _rhs);
/// @desc	Do given matrices match for piecewise math, or is either a scalar (1x1)
/// @param	{Struct.TiteGpuMatrix} _lhs
/// @param	{Struct.TiteGpuMatrix} _rhs
function tite_gpu_match_piecewise(_lhs, _rhs)
{
	return ((_lhs.size[0] == _rhs.size[0]) && ((_lhs.size[1] == _rhs.size[1])))
		|| ((_lhs.size[0] == 1) && (_lhs.size[1] == 1))	 // Allow scalar.
		|| ((_rhs.size[0] == 1) && (_rhs.size[1] == 1)); // 
}










