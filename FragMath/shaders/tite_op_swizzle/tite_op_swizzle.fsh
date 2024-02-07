precision highp float;
uniform sampler2D texA;
uniform vec2 uniTexelA;
uniform int uniR;
uniform int uniG;
uniform int uniB;
uniform int uniA;

void main()
{
	// Get the input value.
	vec4 _lhs = texture2D(texA, gl_FragCoord.xy * uniTexelA);
	
	// Do the calculation.
	vec4 _out;
	#ifdef _YY_HLSL11_
		_out = vec4(_lhs[uniR], _lhs[uniG], _lhs[uniB], _lhs[uniA]);
	#else
		// To work in WebGL, as array indexes must be constants.
		_out[0] = (uniR == 0) ? _lhs[0] : ((uniR == 1) ? _lhs[1] : ((uniR == 2) ? _lhs[2] : _lhs[3]));
		_out[1] = (uniG == 0) ? _lhs[0] : ((uniG == 1) ? _lhs[1] : ((uniG == 2) ? _lhs[2] : _lhs[3]));
		_out[2] = (uniB == 0) ? _lhs[0] : ((uniB == 1) ? _lhs[1] : ((uniB == 2) ? _lhs[2] : _lhs[3]));
		_out[3] = (uniA == 0) ? _lhs[0] : ((uniA == 1) ? _lhs[1] : ((uniA == 2) ? _lhs[2] : _lhs[3]));
	#endif

	// Store the result.
	gl_FragData[0] = _out;
}
