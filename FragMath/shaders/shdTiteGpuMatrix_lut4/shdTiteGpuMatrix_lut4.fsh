precision highp float;
#define texA gm_BaseTexture
uniform sampler2D texB;
uniform vec2 uniTexelA;
uniform vec2 uniTexelLUT;
uniform vec2 uniFactor;
uniform float uniFunc;

void main()
{
	// Get the input value.
	vec4 _out;
	vec4 _lhs = texture2D(texA, gl_FragCoord.xy * uniTexelA);
	
	// Get the output value from lookup table.
	// Normalize the input value to the lut range.
	for(int i = 0; i < 4; i++)
	{
		_lhs[i] = (_lhs[i] - uniFactor[0]) * uniFactor[1];
		_out[i] = texture2D(texB, vec2(_lhs[i], uniFunc + 0.5) * uniTexelLUT)[0];
	}
	
	// Store the result.
	gl_FragData[0] = _out;
}

