/// @desc VISUALIZE PARTICLES

if (vertexBuffer == undefined) 
	exit;

shader_set(shdTiteGpu_Example1);
vertex_submit(vertexBuffer, pr_pointlist, -1);
shader_reset();



