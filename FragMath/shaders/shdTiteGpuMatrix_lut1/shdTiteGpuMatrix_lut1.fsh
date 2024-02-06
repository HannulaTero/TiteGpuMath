precision highp float;
#define texA gm_BaseTexture
uniform sampler2D texB;
uniform vec2 uniTexelA;
uniform vec2 uniTexelLUT;
uniform vec2 uniFactor;

void main()
{
	// Get the input value.
	vec4 _out;
	vec4 _lhs = texture2D(texA, gl_FragCoord.xy * uniTexelA);
	
	// Get the output value from lookup table.
	// Normalize the input value to the lut range.
	_lhs = (_lhs - uniFactor[0]) * uniFactor[1];
	_out = texture2D(texB, vec2(_lhs.x, 0.5) * uniTexelLUT)[0];
	
	// Store the result.
	gl_FragData[0] = _out;
}

