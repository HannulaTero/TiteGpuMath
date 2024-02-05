/// @desc DRAW PARTICLES

// Visualization of particles.
if (vertexBuffer != undefined)
{
	shader_set(shdTiteGpuMatrix_Example);
	vertex_submit(vertexBuffer, pr_pointlist, -1);
	shader_reset();
}
