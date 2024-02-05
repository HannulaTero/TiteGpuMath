attribute vec2 in_Pos;
attribute vec2 in_Off;

uniform sampler2D texA;
uniform vec2 uniTexelA;
uniform vec2 uniOffset;

void main()
{
	vec2 _coord = (in_Pos + uniOffset + 0.5) * uniTexelA;
	vec2 _position = texture2DLod(texA, _coord, 0.0).xy;
	_position += in_Off;
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(_position, 0.0, 1.0);
}
