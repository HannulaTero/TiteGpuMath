
/// @func	tite_error(_msg);
/// @desc	Throws error message.
/// @param	{String} _msg
function tite_error(_msg)
{
	tite_forceinline;
	throw($"[TiteGpu][Error] {_msg}");
}


/// @func	tite_warning(_msg);
/// @desc	Prompts a warning, but doesn't throw error.
/// @param	{String} _msg
function tite_warning(_msg)
{
	tite_forceinline;
	show_debug_message($"[TiteGpu][Warning] {_msg}");
}


/// @func	tite_mapping(_array);
/// @desc	Helper function to create mapping out of array.
/// @param	{Array<Any>}	_array	Values should be key-value pairs 
function tite_mapping(_array)
{
	tite_forceinline;
	var _map = {};
	var _count = array_length(_array);
	for(var i = 0; i < _count; i+=2)
	{
		_map[$ _array[i+0]] = _array[i+1];
	}
	return _map;
}
	
	
/// @func	tite_inplace(_func, _args);
/// @desc	Doing calculations when output should also be an input. Assumes first argument is target. 
/// @param	{Function}		_func	
/// @param	{Array<Any>}	_args	
function tite_inplace(_func, _args)
{
	// Render source and destination can't be same.
	// Therefore temporary target is created, and then results are copied over.
	tite_forceinline;
	var _out = _args[0];
	_args[0] = _out.Clone();
	script_execute_ext(_func, _args);
	// feather ignore GM2023
	tite_begin();
	surface_copy(_out.Surface(), 0, 0, _args[0].Surface());
	tite_end();
	_args[0].Free();
	_args[0] = _out;
	return _out;
}


/// @func	tite_match_piecewise(_lhs, _rhs);
/// @desc	Do given matrices match for piecewise math, or is either a scalar (1x1)
/// @param	{Struct.TiteData} _lhs
/// @param	{Struct.TiteData} _rhs
/// @return	{Bool}
function tite_match_piecewise(_lhs, _rhs)
{
	tite_forceinline;
	return ((_lhs.size[0] == _rhs.size[0]) && ((_lhs.size[1] == _rhs.size[1])))
		|| ((_lhs.size[0] == 1) && (_lhs.size[1] == 1))	 // Allow scalar.
		|| ((_rhs.size[0] == 1) && (_rhs.size[1] == 1)); // 
}


/// @func	tite_assert_piecewise(_lhs, _rhs);
/// @desc	Forces piecewise math to have matching size, or scalar. Otherwise error.
/// @param	{Struct.TiteData} _lhs
/// @param	{Struct.TiteData} _rhs
function tite_assert_piecewise(_lhs, _rhs)
{
	tite_forceinline;
	if (!tite_match_piecewise(_lhs, _rhs))
	{
		tite_error(
			+ $"Piecewise operation require matching matrix size, or scalars. \n"
			+ $" - Got:\n - {_lhs.name} : {_lhs.size}\n - {_rhs.name} : {_rhs.size} \n"
		);
	}
}

