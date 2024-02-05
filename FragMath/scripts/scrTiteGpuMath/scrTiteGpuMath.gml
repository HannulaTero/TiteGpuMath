

/// @func	tite_gpu_math_binary(_out, _lhs, _rhs, _op);
/// @desc	Do operation with two inputs, store result into output.
/// @param	{Struct.TiteGpuMatrix}	_out
/// @param	{Struct.TiteGpuMatrix}	_lhs
/// @param	{Struct.TiteGpuMatrix}	_rhs
/// @param	{Asset.GMShader}		_op		Tite math shader.
function tite_gpu_math_binary(_out, _lhs, _rhs, _op) 
{
	// Trying to do in-place operation.
	if (_out == _lhs) || (_out == _rhs)
	{
		return tite_gpu_inplace(tite_gpu_math_binary, [_out, _lhs, _rhs, _op]);
	}

	// Check dimensionality match.
	tite_gpu_assert_piecewise(_out, _lhs);
	tite_gpu_assert_piecewise(_out, _rhs);
		
	// Do the computation.
	tite_gpu_begin();
	tite_gpu_shader(_op);
	tite_gpu_sample("texA", _lhs);
	tite_gpu_sample("texB", _rhs);
	tite_gpu_floatN("uniTexelA", _lhs.texel);
	tite_gpu_floatN("uniTexelB", _rhs.texel);
	tite_gpu_target(_out);
	tite_gpu_render();
	tite_gpu_finish();
	tite_gpu_end();
	return _out;
}


/// @func	tite_gpu_math_unary(_out, _src, _op);
/// @desc	Do operation with one inputs, store result into output.
/// @param	{Struct.TiteGpuMatrix}	_out
/// @param	{Struct.TiteGpuMatrix}	_src
/// @param	{Asset.GMShader}		_op		Tite math shader.
function tite_gpu_math_unary(_out, _src, _op)
{
	// Trying to do in-place operation.
	if (_out == _src)
	{
		return tite_gpu_inplace(tite_gpu_math_unary, [_out, _src, _op]);
	}

	// Check dimensionality match.
	tite_gpu_assert_piecewise(_out, _src);
		
	// Do the computation.
	tite_gpu_begin();
	tite_gpu_shader(_op);
	tite_gpu_sample("texA", _src);
	tite_gpu_floatN("uniTexelA", _src.texel);
	tite_gpu_target(_out);
	tite_gpu_render();
	tite_gpu_finish();
	tite_gpu_end();
	return _out;
}


/// @func	tite_gpu_math_dot(_out, _lhs, _rhs, _axis);
/// @desc	Do dot product between to matrices with given axis.
/// @param	{Struct.TiteGpuMatrix}	_out
/// @param	{Struct.TiteGpuMatrix}	_lhs
/// @param	{Struct.TiteGpuMatrix}	_rhs
/// @param	{Array<Real>}			_axis	Which dimension is sumreduced.
function tite_gpu_math_dot(_out, _lhs, _rhs, _axis=[1, 0])
{
	// Trying to do in-place operation.
	if (_out == _lhs) || (_out == _rhs)
	{
		return tite_gpu_inplace(tite_gpu_math_dot, [_out, _lhs, _rhs, _axis]);
	}
		
	// Check target axis compatibility.
	if (_lhs.size[_axis[0]] != _rhs.size[_axis[1]])
	{
		tite_gpu_error(
			+ $"Dot product: target axis do not match. \n"
			+ $" - Given target axis: {_lhs.size[_axis[0]]} and {_rhs.size[_axis[1]]}\n"
			+ $" - Operators:\n - {_lhs.name} : {_lhs.size}\n - {_rhs.name} : {_rhs.size}\n"
		);
	}
	
	// Check whether dimensionality is correct.
	if (_out.size[0] != _lhs.size[!_axis[0]])
	|| (_out.size[1] != _rhs.size[!_axis[1]])
	{
		tite_gpu_error(
			+ $"Dot product: output size is incorrect. \n"
			+ $" - Output size was: {_out.size} \n"
			+ $" - Output should be: [{_lhs.size[!_axis[0]]}, {_rhs.size[!_axis[1]]}]"
		);
	}
		
	// Select axis which stay, and which are stepped upon.
	var _startA = [real(_axis[0] == 1), real(_axis[0] == 0)];
	var _startB = [real(_axis[1] == 1), real(_axis[1] == 0)];
	var _stepsA = [_startA[0] ? 0.0 : _lhs.texel[0], _startA[1] ? 0.0 : _lhs.texel[1]];
	var _stepsB = [_startB[2] ? 0.0 : _rhs.texel[0], _startB[1] ? 0.0 : _rhs.texel[1]];
	var _iterations = _lhs.shape[_axis[0]];
	
	// Do the computation.
	tite_gpu_begin();
	tite_gpu_shader(shdTiteGpuMatrix_dot);
	tite_gpu_sample("texA", _lhs);
	tite_gpu_sample("texB", _rhs);
	tite_gpu_floatN("uniTexelA", _lhs.texel);
	tite_gpu_floatN("uniTexelB", _rhs.texel);
	tite_gpu_floatN("uniStartA", _startA);
	tite_gpu_floatN("uniStartB", _startB);
	tite_gpu_floatN("uniStepsA", _stepsA);
	tite_gpu_floatN("uniStepsB", _stepsB);
	tite_gpu_float1("uniIterations", _iterations);
	tite_gpu_target(_out);
	tite_gpu_render();
	tite_gpu_finish();
	tite_gpu_end();
	return _out;
}


/// @func	tite_gpu_math_clamp(_out, _src, _min, _max);
/// @desc	Clamping function. 
/// @param	{Struct.TiteGpuMatrix}	_out
/// @param	{Struct.TiteGpuMatrix}	_src
/// @param	{Any}					_min
/// @param	{Any}					_max
function tite_gpu_math_clamp(_out, _src, _min=undefined, _max=undefined)
{
	// Trying to do in-place operation.
	if (_out == _src)
	{
		return tite_gpu_inplace(tite_gpu_math_clamp, [_out, _src, _min, _max]);
	}

	// Check dimensionality match.
	tite_gpu_assert_piecewise(_out, _src);
		
	// Do the computation.
	tite_gpu_begin();
	tite_gpu_shader(shdTiteGpuMatrix_clamp);
	tite_gpu_sample("texA", _src);
	tite_gpu_floatN("uniTexelA", _src.texel);
	tite_gpu_float4_any("uniMin", _min ?? 0);
	tite_gpu_float4_any("uniMax", _min ?? 1);
	tite_gpu_target(_out);
	tite_gpu_render();
	tite_gpu_finish();
	tite_gpu_end();
	return _out;
}


/// @func	tite_gpu_math_mix(_out, _lhs, _rhs, _rate);
/// @desc	Lerping/mixing function. 
/// @param	{Struct.TiteGpuMatrix}	_out
/// @param	{Struct.TiteGpuMatrix}	_lhs
/// @param	{Struct.TiteGpuMatrix}	_rhs
/// @param	{Any}					_rate
function tite_gpu_math_mix(_out, _lhs, _rhs, _rate=undefined)
{
	// Trying to do in-place operation.
	if (_out == _lhs)
	{
		return tite_gpu_inplace(tite_gpu_math_mix, [_out, _lhs, _rhs, _rate]);
	}

	// Check dimensionality match.
	tite_gpu_assert_piecewise(_out, _lhs);
	tite_gpu_assert_piecewise(_out, _rhs);
		
	// Do the computation.
	tite_gpu_begin();
	tite_gpu_shader(shdTiteGpuMatrix_mix);
	tite_gpu_sample("texA", _lhs);
	tite_gpu_sample("texB", _rhs);
	tite_gpu_floatN("uniTexelA", _lhs.texel);
	tite_gpu_floatN("uniTexelB", _rhs.texel);
	tite_gpu_float4_any("uniRate", _rate ?? 0.5);
	tite_gpu_target(_out);
	tite_gpu_render();
	tite_gpu_finish();
	tite_gpu_end();
	return _out;
}


/// @func	tite_gpu_math_offset(_out, _src, _offset);
/// @desc	Do operation with one inputs, store result into output.
/// @param	{Struct.TiteGpuMatrix}	_out
/// @param	{Struct.TiteGpuMatrix}	_src
/// @param	{Any}					_offset
function tite_gpu_math_offset(_out, _src, _offset=undefined)
{
	// Trying to do in-place operation.
	if (_out == _src)
	{
		return tite_gpu_inplace(tite_gpu_math_offset, [_out, _src, _offset]);
	}

	// Check dimensionality match.
	tite_gpu_assert_piecewise(_out, _src);
		
	// Do the computation.
	tite_gpu_begin();
	tite_gpu_shader(shdTiteGpuMatrix_offset);
	tite_gpu_sample("texA", _src);
	tite_gpu_floatN("uniTexelA", _src.texel);
	tite_gpu_float4_any("uniOffset", _offset ?? 0.0);
	tite_gpu_target(_out);
	tite_gpu_render();
	tite_gpu_finish();
	tite_gpu_end();
	return _out;
}


/// @func	tite_gpu_math_scale(_out, _src, _scale);
/// @desc	Do operation with one inputs, store result into output.
/// @param	{Struct.TiteGpuMatrix}	_out
/// @param	{Struct.TiteGpuMatrix}	_src
/// @param	{Any}					_scale
function tite_gpu_math_scale(_out, _src, _scale=undefined)
{
	// Trying to do in-place operation.
	if (_out == _src)
	{
		return tite_gpu_inplace(tite_gpu_math_scale, [_out, _src, _scale]);
	}

	// Check dimensionality match.
	tite_gpu_assert_piecewise(_out, _src);
		
	// Do the computation.
	tite_gpu_begin();
	tite_gpu_shader(shdTiteGpuMatrix_scale);
	tite_gpu_sample("texA", _src);
	tite_gpu_floatN("uniTexelA", _src.texel);
	tite_gpu_float4_any("uniScale", _scale ?? 1.0);
	tite_gpu_target(_out);
	tite_gpu_render();
	tite_gpu_finish();
	tite_gpu_end();
	return _out;
}


/// @func	tite_gpu_math_normalize(_out, _src, _min, _max);
/// @desc	Normalizes the values into given range. Doesn't clamp.
/// @param	{Struct.TiteGpuMatrix}	_out
/// @param	{Struct.TiteGpuMatrix}	_src
/// @param	{Any}					_min
/// @param	{Any}					_max
function tite_gpu_math_normalize(_out, _src, _min=undefined, _max=undefined)
{
	// Trying to do in-place operation.
	if (_out == _src)
	{
		return tite_gpu_inplace(tite_gpu_math_normalize, [_out, _src, _min, _max]);
	}

	// Check dimensionality match.
	tite_gpu_assert_piecewise(_out, _src);
		
	// Do the computation.
	tite_gpu_begin();
	tite_gpu_shader(shdTiteGpuMatrix_normalize);
	tite_gpu_sample("texA", _src);
	tite_gpu_floatN("uniTexelA", _src.texel);
	tite_gpu_float4_any("uniMin", _min);
	tite_gpu_float4_any("uniMax", _max);
	tite_gpu_target(_out);
	tite_gpu_render();
	tite_gpu_finish();
	tite_gpu_end();
	return _out;
}


/// @func	tite_gpu_math_set(_out, _values);
/// @desc	Set whole surface to specific value.
/// @param	{Struct.TiteGpuMatrix}	_out
/// @param	{Any}					_values
function tite_gpu_math_set(_out, _values=undefined)
{
	// Do the computation.
	tite_gpu_begin();
	tite_gpu_shader(shdTiteGpuMatrix_set);
	tite_gpu_float4_any("uniOffset", _values ?? 0);
	tite_gpu_target(_out);
	tite_gpu_render();
	tite_gpu_finish();
	tite_gpu_end();
	return _out;
}



/// @func	tite_gpu_math_randomize(_out, _min, _max, _seedX, _seedY);
/// @desc	Randomizes the target.
/// @param	{Struct.TiteGpuMatrix} _out
/// @param	{Any} _min
/// @param	{Any} _max
/// @param	{Any} _seedX
/// @param	{Any} _seedY
function tite_gpu_math_randomize(_out, _min=undefined, _max=undefined, _seedX=undefined, _seedY=undefined)
{
	_seedX ??= (current_time mod 2777) / 2777.0;
	_seedY ??= (current_time mod 1097) / 1097.0;
	tite_gpu_begin();
	tite_gpu_shader(shdTiteGpuMatrix_randomize);
	tite_gpu_floatN("uniTexelA", _out.texel);
	tite_gpu_float4_any("uniMin", _min ?? 0);
	tite_gpu_float4_any("uniMax", _max ?? 0);
	tite_gpu_float4_any("uniSeedX", _seedX);
	tite_gpu_float4_any("uniSeedY", _seedY);
	tite_gpu_float4("uniFactor", 2.12, 2.34, 2.56, 2.78);
	tite_gpu_target(_out);
	tite_gpu_render();
	tite_gpu_finish();
	tite_gpu_end();
	return _out;
}



