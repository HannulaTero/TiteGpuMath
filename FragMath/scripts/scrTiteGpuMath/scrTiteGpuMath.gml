

/// @func	tite_gpu_math_binary(_out, _lhs, _rhs, _op);
/// @desc	Do operation with two inputs, store result into output.
/// @param	{Struct.TiteGpuMatrix}	_out
/// @param	{Struct.TiteGpuMatrix}	_lhs
/// @param	{Struct.TiteGpuMatrix}	_rhs
/// @param	{Asset.GMShader}		_op		Tite math shader.
function tite_gpu_math_binary(_out, _lhs, _rhs, _op) 
{
	// Trying to do in-place operation.
	if (_rhs == undefined)
	{
		_rhs = _lhs;
		_lhs = _out;
	}
	if (_out == _lhs) || (_out == _rhs)
	{
		return tite_gpu_inplace(tite_gpu_math_binary, [_out, _lhs, _rhs, _op]);
	}

	// Check dimensionality match.
	if (!tite_gpu_match_piecewise(_out, _lhs))
	|| (!tite_gpu_match_piecewise(_out, _rhs))
	{
		throw($"Piecewise math: Output and Inputs dimensions do not match.");
	}
		
	// Do the computation.
	tite_gpu_begin();
	tite_gpu_shader(_op);
	tite_gpu_floatN("texelA", _lhs.texel);
	tite_gpu_floatN("texelB", _rhs.texel);
	tite_gpu_sample("texA", _lhs);
	tite_gpu_sample("texB", _rhs);
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
	if (!tite_gpu_match_piecewise(_out, _src))
	{
		throw($"Piecewise math: Output and Input dimensions do not match.");
	}
		
	// Do the computation.
	tite_gpu_begin();
	tite_gpu_shader(_op);
	tite_gpu_floatN("texelA", _src.texel);
	tite_gpu_sample("texA", _src);
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
		
	// Check dimensionality.
	if (_lhs.size[_axis[0]] != _rhs.size[_axis[1]])
	{
		throw($"Dot product: target axis do not match.");
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
	tite_gpu_floatN("uniTexelA", _lhs.texel);
	tite_gpu_floatN("uniTexelB", _rhs.texel);
	tite_gpu_floatN("uniStartA", _startA);
	tite_gpu_floatN("uniStartB", _startB);
	tite_gpu_floatN("uniStepsA", _stepsA);
	tite_gpu_floatN("uniStepsB", _stepsB);
	tite_gpu_float1("uniIterations", _iterations);
	tite_gpu_sample("texA", _lhs);
	tite_gpu_sample("texB", _rhs);
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
/// @param	{Real}					_min
/// @param	{Real}					_max
function tite_gpu_math_clamp(_out, _src, _min, _max)
{
	// Trying to do in-place operation.
	if (_out == _src)
	{
		return tite_gpu_inplace(tite_gpu_math_clamp, [_out, _src, _min, _max]);
	}

	// Check dimensionality match.
	if (!tite_gpu_match_piecewise(_out, _src))
	{
		throw($"Piecewise math: Output and Input dimensions do not match.");
	}
		
	// Do the computation.
	tite_gpu_begin();
	tite_gpu_shader(shdTiteGpuMatrix_clamp);
	tite_gpu_floatN("texelA", _src.texel);
	tite_gpu_float2("uniRange", _min, _max);
	tite_gpu_sample("texA", _src);
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
/// @param	{Real}					_rate
function tite_gpu_math_mix(_out, _lhs, _rhs, _rate)
{
	// Trying to do in-place operation.
	if (_out == _lhs)
	{
		return tite_gpu_inplace(tite_gpu_math_mix, [_out, _lhs, _rhs, _rate]);
	}

	// Check dimensionality match.
	if (!tite_gpu_match_piecewise(_out, _lhs))
	|| (!tite_gpu_match_piecewise(_out, _rhs))
	{
		throw($"Piecewise math: Output and Input dimensions do not match.");
	}
		
	// Do the computation.
	tite_gpu_begin();
	tite_gpu_shader(shdTiteGpuMatrix_mix);
	tite_gpu_floatN("texelA", _lhs.texel);
	tite_gpu_floatN("texelB", _rhs.texel);
	tite_gpu_float1("uniRate", _rate);
	tite_gpu_sample("texA", _lhs);
	tite_gpu_sample("texB", _rhs);
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
/// @param	{Real}					_offset
function tite_gpu_math_offset(_out, _src, _offset)
{
	// Trying to do in-place operation.
	if (_out == _src)
	{
		return tite_gpu_inplace(tite_gpu_math_offset, [_out, _src, _offset]);
	}

	// Check dimensionality match.
	if (!tite_gpu_match_piecewise(_out, _src))
	{
		throw($"Piecewise math: Output and Input dimensions do not match.");
	}
		
	// Do the computation.
	tite_gpu_begin();
	tite_gpu_shader(shdTiteGpuMatrix_offset);
	tite_gpu_floatN("texelA", _src.texel);
	tite_gpu_float1("uniOffset", _offset);
	tite_gpu_sample("texA", _src);
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
/// @param	{Real}					_scale
function tite_gpu_math_scale(_out, _src, _scale)
{
	// Trying to do in-place operation.
	if (_out == _src)
	{
		return tite_gpu_inplace(tite_gpu_math_scalar, [_out, _src, _scale]);
	}

	// Check dimensionality match.
	if (!tite_gpu_match_piecewise(_out, _src))
	{
		throw($"Piecewise math: Output and Input dimensions do not match.");
	}
		
	// Do the computation.
	tite_gpu_begin();
	tite_gpu_shader(shdTiteGpuMatrix_scale);
	tite_gpu_floatN("texelA", _src.texel);
	tite_gpu_float1("uniScale", _scale);
	tite_gpu_sample("texA", _src);
	tite_gpu_target(_out);
	tite_gpu_render();
	tite_gpu_finish();
	tite_gpu_end();
	return _out;
}


/// @func	tite_gpu_math_randomize(_out, _min, _max, _seed);
/// @desc	Randomizes the target.
/// @param	{Struct.TiteGpuMatrix} _out
/// @param	{Real} _min
/// @param	{Real} _max
/// @param	{Real} _seed
function tite_gpu_math_randomize(_out, _min=0, _max=1, _seed=undefined)
{
	_seed ??= get_timer() / 1_000_000;
	tite_gpu_begin();
	tite_gpu_shader(shdTiteGpuMatrix_randomize);
	tite_gpu_float2("uniRange", _min, _max);
	tite_gpu_float4("uniSeed", _seed+0, _seed+1, _seed+2, _seed+3);
	tite_gpu_target(_out);
	tite_gpu_render();
	tite_gpu_finish();
	tite_gpu_end();
	return _out;
}



