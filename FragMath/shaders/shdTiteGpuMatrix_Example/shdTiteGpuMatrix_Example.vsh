attribute vec4 in_Pos; // in_Position is reserved.

void main()
{
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Pos.xyz, 1.0);
}
