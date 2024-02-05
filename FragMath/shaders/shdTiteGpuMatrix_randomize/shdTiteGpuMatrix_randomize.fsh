varying vec2 vCoord;

uniform vec2 uniSeed[4];
uniform vec2 uniRange;

float random(vec2 _seed) 
{
    return fract(sin(dot(_seed.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main()
{
	// Do the calculation.
	vec4 _out = vec4(
		mix(uniRange[0], uniRange[1], random(vCoord * 12.34 + uniSeed[0])),
		mix(uniRange[0], uniRange[1], random(vCoord * 34.56 + uniSeed[1])),
		mix(uniRange[0], uniRange[1], random(vCoord * 56.78 + uniSeed[2])),
		mix(uniRange[0], uniRange[1], random(vCoord * 78.90 + uniSeed[3]))
	);

	// Store the result.
	gl_FragData[0] = _out;
}
