precision highp float;
uniform vec2 uniSize;

void main()
{
	vec2 _coord = floor(gl_FragCoord.xy);
	float _index = _coord.x + uniSize.x * _coord.y;
	gl_FragData[0] = vec4(_index, 0.0, 0.0, 1.0);
}
