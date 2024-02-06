precision highp float;
uniform sampler2D texA;
uniform vec2 uniTexelA;

void main()
{
	gl_FragData[0] = texture2D(texA, gl_FragCoord.yx * uniTexelA);
}
