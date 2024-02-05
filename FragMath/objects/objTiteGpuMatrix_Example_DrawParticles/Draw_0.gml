/// @desc VISUALIZE PARTICLES

if (vertexBuffer == undefined) 
{
	exit;
}

shader_set(shdTiteGpuMatrix_Example);
vertex_submit(vertexBuffer, pr_pointlist, -1);
shader_reset();























































