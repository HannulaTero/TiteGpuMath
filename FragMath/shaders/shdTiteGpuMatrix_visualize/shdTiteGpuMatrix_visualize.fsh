precision highp float;
varying vec2 vCoord;
uniform vec2 uniFactor;

void main()
{
	vec4 _lhs = texture2D(gm_BaseTexture, vCoord);
	vec4 _out = (_lhs - uniFactor[0]) / (uniFactor[1] - uniFactor[0]);
	gl_FragData[0] = _out;
}
