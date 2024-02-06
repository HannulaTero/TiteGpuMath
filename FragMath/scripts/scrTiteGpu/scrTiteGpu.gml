
#macro tite_gpu_forceinline gml_pragma("forceinline")


// Helper global variables.
global.tite_gpu = {}; 
global.tite_gpu.previousShader = [-1];		// Stores so it can be return after calculations are done.
global.tite_gpu.cumulative = false;			// Store next calculation as cumulative result.
global.tite_gpu.vertexFormat = undefined;
global.tite_gpu.vertexBuffer = undefined;


// Create vertex format and buffer to render whole render area.
// Calculations are assumed to use simplified vertex shader, 
// so it won't add any projections. Vbuff assumes pr_trianglestrip.
vertex_format_begin();
vertex_format_add_position();
global.tite_gpu.vertexFormat = vertex_format_end();
global.tite_gpu.vertexBuffer = vertex_create_buffer();
var _vbuff = global.tite_gpu.vertexBuffer;
vertex_begin(_vbuff, global.tite_gpu.vertexFormat);
vertex_position(_vbuff, -1.0, -1.0);
vertex_position(_vbuff, +1.0, -1.0);
vertex_position(_vbuff, -1.0, +1.0);
vertex_position(_vbuff, +1.0, +1.0);
vertex_end(_vbuff);
vertex_freeze(_vbuff);


/// @func	tite_gpu_begin();
/// @desc	Changes gpu states to more suitable for calculations.
function tite_gpu_begin()
{
	tite_gpu_forceinline;
	gpu_push_state();
	gpu_set_alphatestenable(false);
	gpu_set_tex_filter(false);
	gpu_set_tex_repeat(false);
	if (global.tite_gpu.cumulative) 
	{
		gpu_set_blendenable(true);
		gpu_set_blendmode_ext(bm_one, bm_one);
	} else {
		gpu_set_blendenable(false);
		gpu_set_blendmode_ext(bm_one, bm_zero);
	}
}


/// @func	tite_gpu_finish();
/// @desc	Computing to target is finished. As separate if other functionality is later added.
function tite_gpu_finish()
{
	tite_gpu_forceinline;
	surface_reset_target();
}


/// @func	tite_gpu_end();
/// @desc	Returns previous gpu state.
function tite_gpu_end()
{
	tite_gpu_forceinline;
	gpu_pop_state();
	var _shader = array_pop(global.tite_gpu.previousShader);
	if (_shader != -1)
		shader_set(_shader);
	else
		shader_reset();
	global.tite_gpu.cumulative = false;
}


/// @func	tite_gpu_shader(_shader);
/// @desc	Select tite operation.
/// @param	{Asset.GMShader} _shader
function tite_gpu_shader(_shader) 
{
	tite_gpu_forceinline;
	array_push(global.tite_gpu.previousShader, shader_current());
	shader_set(_shader);
}


/// @func	tite_gpu_set_cumulative(_bool);
/// @desc	Whether results are "set" or "add" to destination. 
/// @param	{Bool} _additive
function tite_gpu_set_cumulative(_additive=true) 
{
	tite_gpu_forceinline;
	global.tite_gpu.cumulative = _additive;
}


/// @func	tite_gpu_float4_any(_name, _values);
/// @desc	Forces 4 items into uniform from given value.
/// @param	{String}		_name
/// @param	{Any}			_values Number or Array
function tite_gpu_float4_any(_name, _values)
{
	tite_gpu_forceinline;
	if (is_array(_values)) 
	{
		var _array = [0, 0, 0, 0];
		array_copy(_array, 0, _values, 0, max(4, array_length(_values)));
		tite_gpu_floatN(_name, _array);
		array_resize(_array, 0);
	} else {
		_values ??= 0;
		tite_gpu_float4(_name, _values, _values, _values, _values);
	}
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
/// @desc	Set matrix as texture sampler, input for operation.
/// @param	{String}				_name
/// @param	{Struct.TiteGpuMatrix}	_src
function tite_gpu_sample(_name, _src)
{
	var _shader = shader_current();
	var _sampler = shader_get_sampler_index(_shader, _name);
	gpu_set_tex_filter_ext(_sampler, _src.interpolate);
	gpu_set_tex_repeat_ext(_sampler, _src.repetive);
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
	
	
/// @func	tite_gpu_render();
/// @desc	Do the calculation, updates whole target.
function tite_gpu_render()
{
	tite_gpu_forceinline;
	vertex_submit(global.tite_gpu.vertexBuffer, pr_trianglestrip, -1);
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
	tite_gpu_begin();
	surface_copy(_out.Surface(), 0, 0, _args[0].Surface());
	tite_gpu_end();
	_args[0].Free();
	_args[0] = _out;
	return _out;
}


/// @func	tite_gpu_error(_msg);
/// @desc	Throws error message.
/// @param	{String} _msg
function tite_gpu_error(_msg)
{
	tite_gpu_forceinline;
	throw($"[TiteGpu][Error] {_msg}");
}


/// @func	tite_gpu_warning(_msg);
/// @desc	Prompts a warning, but doesn't throw error.
/// @param	{String} _msg
function tite_gpu_warning(_msg)
{
	tite_gpu_forceinline;
	show_debug_message($"[TiteGpu][Warning] {_msg}");
}


/// @func	tite_gpu_match_piecewise(_lhs, _rhs);
/// @desc	Do given matrices match for piecewise math, or is either a scalar (1x1)
/// @param	{Struct.TiteGpuMatrix} _lhs
/// @param	{Struct.TiteGpuMatrix} _rhs
/// @return	{Bool}
function tite_gpu_match_piecewise(_lhs, _rhs)
{
	tite_gpu_forceinline;
	return ((_lhs.size[0] == _rhs.size[0]) && ((_lhs.size[1] == _rhs.size[1])))
		|| ((_lhs.size[0] == 1) && (_lhs.size[1] == 1))	 // Allow scalar.
		|| ((_rhs.size[0] == 1) && (_rhs.size[1] == 1)); // 
}


/// @func	tite_gpu_assert_piecewise(_lhs, _rhs);
/// @desc	Forces piecewise math to have matching size, or scalar. Otherwise error.
/// @param	{Struct.TiteGpuMatrix} _lhs
/// @param	{Struct.TiteGpuMatrix} _rhs
function tite_gpu_assert_piecewise(_lhs, _rhs)
{
	tite_gpu_forceinline;
	if (!tite_gpu_match_piecewise(_lhs, _rhs))
	{
		tite_gpu_error(
			+ $"Piecewise operation require matching matrix size, or scalars. \n"
			+ $" - Got:\n - {_lhs.name} : {_lhs.size}\n - {_rhs.name} : {_rhs.size} \n"
		);
	}
}


/// @func	tite_gpu_mapping(_array);
/// @desc	Helper function to create mapping out of array.
/// @param	{Array<Any>}	_array	Values should be key-value pairs 
function tite_gpu_mapping(_array)
{
	tite_gpu_forceinline;
	var _map = {};
	var _count = array_length(_array);
	for(var i = 0; i < _count; i+=2)
	{
		_map[$ _array[i+0]] = _array[i+1];
	}
	return _map;
}


/// @func	tite_gpu_find_supported_format(_format);
/// @desc	Helper function to find closest supported surface format. 
/// @param	{Constant.SurfaceFormatType} _format	
function tite_gpu_find_supported_format(_format)
{
	tite_gpu_forceinline;
	// Map out replacement, if given format is not suitable.
	// Assumes rgba8unorm is always accepted.
	static __map = tite_gpu_mapping([
		surface_rgba32float,	surface_rgba16float,
		surface_rgba16float,	surface_rgba8unorm,
		surface_r32float,		surface_r16float,
		surface_r16float,		surface_r8unorm,
		surface_rgba4unorm,		surface_rgba8unorm,	
		surface_rg8unorm,		surface_rgba8unorm,	
		surface_r8unorm,		surface_rgba8unorm,	
		surface_rgba8unorm,		surface_rgba8unorm	// Lowest nominator.
	]);
	
	// Try find best compatible format.
	var _select = _format;
	while(!surface_format_is_supported(_select))
	{
		_select = __map[$ _format] ?? surface_rgba8unorm;
	}
		
	// Give warning of different selected format.
	if (_select != _format)
	{
		tite_gpu_warning(
			+ $"Format {tite_gpu_format_name(_format)} not supported. \n"
			+ $" - Selected format {tite_gpu_format_name(_select)} instead."
		);
	}
	
	// Return the selected format
	return _select;
}


/// @func	tite_gpu_format_name(_format);
/// @desc	Helper function to get format name as string.
/// @param	{Constant.SurfaceFormatType} _format	
function tite_gpu_format_name(_format)
{
	tite_gpu_forceinline;
	static __map = tite_gpu_mapping([
		surface_rgba32float,	"RGBA32Float",
		surface_rgba16float,	"RGBA16Float",
		surface_rgba8unorm,		"RGBA8Unorm",
		surface_rgba4unorm,		"RGBA4Unorm",
		surface_rg8unorm,		"RG8Unorm",
		surface_r8unorm,		"R8Unorm",
		surface_r32float,		"R32Float",
		surface_r16float,		"R16Float"
	]);
	return __map[$ _format] ?? "<unknown surface format>";
}


/// @func	tite_gpu_format_components(_format);
/// @desc	Helper function to get how many components format has.
/// @param	{Constant.SurfaceFormatType} _format	
function tite_gpu_format_components(_format)
{
	tite_gpu_forceinline;
	static __map = tite_gpu_mapping([
		surface_rgba32float,	4,
		surface_rgba16float,	4,
		surface_rgba8unorm,		4,
		surface_rgba4unorm,		4,
		surface_rg8unorm,		2,
		surface_r8unorm,		1,
		surface_r32float,		1,
		surface_r16float,		1
	]);
	return __map[$ _format] ?? 4;
}


/// @func	tite_gpu_format_bytes(_format);
/// @desc	Helper function to get how many bytes format takes per element.
/// @param	{Constant.SurfaceFormatType} _format	
function tite_gpu_format_bytes(_format)
{
	tite_gpu_forceinline;
	static __map = tite_gpu_mapping([
		surface_rgba32float,	4 * 4,
		surface_rgba16float,	4 * 2,
		surface_rgba8unorm,		4 * 1,
		surface_rgba4unorm,		4 * 0.5,
		surface_rg8unorm,		2 * 1,
		surface_r8unorm,		1 * 1,
		surface_r32float,		1 * 4,
		surface_r16float,		1 * 2
	]);
	return __map[$ _format] ?? 4;
}


/// @func	tite_gpu_format_buffer_dtype(_format);
/// @desc	Helper function to get representative buffer datatype.
/// @param	{Constant.SurfaceFormatType} _format	
function tite_gpu_format_buffer_dtype(_format)
{
	tite_gpu_forceinline;
	static __map = tite_gpu_mapping([
		surface_rgba32float,	buffer_f32,
		surface_rgba16float,	buffer_f16,
		surface_r32float,		buffer_f32,
		surface_r16float,		buffer_f16
	]);
	return __map[$ _format] ?? buffer_u8;
}


