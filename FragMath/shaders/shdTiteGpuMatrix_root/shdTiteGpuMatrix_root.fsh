precision highp float;
#define texA gm_BaseTexture
uniform sampler2D texB;
uniform vec2 uniTexelA;
uniform vec2 uniTexelB;

void main()
{
	// Get the input value.
	vec4 _lhs = texture2D(texA, gl_FragCoord.xy * uniTexelA);
	vec4 _rhs = texture2D(texB, gl_FragCoord.xy * uniTexelB);
	
	// Do the calculation.
	vec4 _out = pow(_lhs, 1.0 / _rhs);

	// Store the result.
	gl_FragData[0] = _out;
}
