precision highp float;
uniform sampler2D texA;
uniform vec2 uniTexelA;
uniform vec4 uniMin;
uniform vec4 uniMax;

void main()
{
	// Get the input value.
	vec4 _lhs = texture2D(texA, gl_FragCoord.xy * uniTexelA);
	
	// Do the calculation.
	vec4 _out = (_lhs - uniMin) / (uniMax - uniMin);

	// Store the result.
	gl_FragData[0] = _out;
}
