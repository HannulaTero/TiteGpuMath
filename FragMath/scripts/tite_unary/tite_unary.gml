


/// @func	tite_unary(_out, _src, _op);
/// @desc	Do operation with one inputs, store result into output.
/// @param	{Struct.TiteData}	_out
/// @param	{Struct.TiteData}	_src
/// @param	{Asset.GMShader}		_op		Tite math shader.
function tite_unary(_out, _src, _op)
{
	// Trying to do in-place operation.
	if (_out == _src)
		return tite_inplace(tite_unary, [_out, _src, _op]);
		
	// Do the computation.
	tite_begin();
	tite_shader(_op);
	tite_sample("texA", _src);
	tite_floatN("uniTexelA", _src.texel);
	tite_target(_out);
	tite_render();
	tite_finish();
	tite_end();
	return _out;
}