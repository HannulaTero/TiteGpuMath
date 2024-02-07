precision highp float;

void main()
{
	gl_FragData[0] = vec4(floor(gl_FragCoord.xy), 0.0, 1.0);
}
