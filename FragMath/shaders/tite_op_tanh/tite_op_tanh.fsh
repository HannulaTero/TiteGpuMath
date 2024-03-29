precision highp float;
uniform sampler2D texA;
uniform vec2 uniTexelA;

void main()
{
	// Get the input value.
	vec4 _lhs = texture2D(texA, gl_FragCoord.xy * uniTexelA);
	
	// Do the calculation.
	vec4 _a = exp(+_lhs);
	vec4 _b = exp(-_lhs);
	vec4 _out = (_a - _b) / (_a + _b);

	// Store the result.
	gl_FragData[0] = _out;
}
