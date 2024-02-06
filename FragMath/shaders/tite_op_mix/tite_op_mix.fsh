precision highp float;
uniform sampler2D texA;
uniform sampler2D texB;
uniform vec2 uniTexelA;
uniform vec2 uniTexelB;
uniform vec4 uniRate;

void main()
{
	// Get the input value.
	vec4 _lhs = texture2D(texA, gl_FragCoord.xy * uniTexelA);
	vec4 _rhs = texture2D(texB, gl_FragCoord.xy * uniTexelB);
	
	// Do the calculation.
	vec4 _out = mix(_lhs, _rhs, uniRate);

	// Store the result.
	gl_FragData[0] = _out;
}
