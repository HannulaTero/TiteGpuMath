#define texA gm_BaseTexture
uniform vec2 uniTexelA;
uniform float uniRange[2];

void main()
{
	// Get the input value.
	vec4 _lhs = texture2D(texA, gl_FragCoord.xy * uniTexelA);
	
	// Do the calculation.
	vec4 _out = clamp(_lhs, vec4(uniRange[0]), vec4(uniRange[1]));

	// Store the result.
	gl_FragData[0] = _out;
}
