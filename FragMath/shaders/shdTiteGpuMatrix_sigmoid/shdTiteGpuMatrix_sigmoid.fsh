#define texA gm_BaseTexture
uniform vec2 uniTexelA;

void main()
{
	// Get the input value.
	vec4 _lhs = texture2D(texA, gl_FragCoord.xy * uniTexelA);
	
	// Do the calculation.
	vec4 _out = 1.0 / (1.0 + exp(-_lhs));

	// Store the result.
	gl_FragData[0] = _out;
}