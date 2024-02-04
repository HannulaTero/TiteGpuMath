varying vec2 vCoord;
uniform vec2 uniSeed;
uniform vec2 uniRange;

float random(vec2 seed) {
    return fract(sin(dot(seed.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main()
{
	// Do the calculation.
	vec4 _out = ;

	// Store the result.
	gl_FragData[0] = _out;
}
