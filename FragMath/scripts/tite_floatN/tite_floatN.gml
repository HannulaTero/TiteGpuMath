
/// @func	tite_floatN(_name, _array);
/// @desc	Set shader uniforms with given name.
/// @param	{String}		_name
/// @param	{Array<Real>}	_array
function tite_floatN(_name, _array)
{
	tite_forceinline;
	var _shader = shader_current();
	var _uniform = shader_get_uniform(_shader, _name);
	shader_set_uniform_f_array(_uniform, _array);
}


/// @func	tite_float1(_name, _x);
/// @desc	Set shader uniforms with given name.
/// @param	{String}	_name
/// @param	{Real}		_x
function tite_float1(_name, _x)
{
	tite_forceinline;
	var _shader = shader_current();
	var _uniform = shader_get_uniform(_shader, _name);
	shader_set_uniform_f(_uniform, _x);
}


/// @func	tite_float2(_name, _x, _y);
/// @desc	Set shader uniforms with given name.
/// @param	{String}	_name
/// @param	{Real}		_x
/// @param	{Real}		_y
function tite_float2(_name, _x, _y)
{
	tite_forceinline;
	var _shader = shader_current();
	var _uniform = shader_get_uniform(_shader, _name);
	shader_set_uniform_f(_uniform, _x, _y);
}


/// @func	tite_float3(_name, _x, _y, _z);
/// @desc	Set shader uniforms with given name.
/// @param	{String}	_name
/// @param	{Real}		_x
/// @param	{Real}		_y
/// @param	{Real}		_z
function tite_float3(_name, _x, _y, _z)
{
	tite_forceinline;
	var _shader = shader_current();
	var _uniform = shader_get_uniform(_shader, _name);
	shader_set_uniform_f(_uniform, _x, _y, _z);
}


/// @func	tite_float4(_name, _x, _y, _z, W);
/// @desc	Set shader uniforms with given name.
/// @param	{String}	_name
/// @param	{Real}		_x
/// @param	{Real}		_y
/// @param	{Real}		_z
/// @param	{Real}		_w
function tite_float4(_name, _x, _y, _z, _w)
{
	tite_forceinline;
	var _shader = shader_current();
	var _uniform = shader_get_uniform(_shader, _name);
	shader_set_uniform_f(_uniform, _x, _y, _z, _w);
}


/// @func	tite_float4_any(_name, _values);
/// @desc	Forces 4 items into uniform from given value.
/// @param	{String}		_name
/// @param	{Any}			_values Number or Array
function tite_float4_any(_name, _values)
{
	tite_forceinline;
	if (is_array(_values)) 
	{
		var _array = [0.0, 0.0, 0.0, 0.0];
		array_copy(_array, 0, _values, 0, max(4, array_length(_values)));
		tite_floatN(_name, _array);
		array_resize(_array, 0);
	} 
	else 
	{
		_values ??= 0.0;
		tite_float4(_name, _values, _values, _values, _values);
	}
}