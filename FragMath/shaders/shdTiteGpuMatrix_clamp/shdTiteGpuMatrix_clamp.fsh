precision highp float;
#define texA gm_BaseTexture
uniform vec2 uniTexelA;
uniform vec4 uniMin;
uniform vec4 uniMax;

void main()
{
	// Get the input value.
	vec4 _lhs = texture2D(texA, gl_FragCoord.xy * uniTexelA);
	
	// Do the calculation.
	vec4 _out = clamp(_lhs, uniMin, uniMax);

	// Store the result.
	gl_FragData[0] = _out;
}
