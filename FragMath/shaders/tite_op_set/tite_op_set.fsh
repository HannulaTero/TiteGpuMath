precision highp float;
uniform vec4 uniValue;

void main()
{
	gl_FragData[0] = uniValue;
}
