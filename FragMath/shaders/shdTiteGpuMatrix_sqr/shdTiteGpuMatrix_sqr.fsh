precision highp float;
#define texA gm_BaseTexture
uniform vec2 uniTexelA;

void main()
{
	// Get the input value.
	vec4 _lhs = texture2D(texA, gl_FragCoord.xy * uniTexelA);
	
	// Do the calculation.
	vec4 _out = _lhs * _lhs;

	// Store the result.
	gl_FragData[0] = _out;
}
