/// @desc VISUALIZE PARTICLES

if (vertexBuffer == undefined) 
	exit;

shader_set(tite_shd_example_particles_bad);
vertex_submit(vertexBuffer, pr_pointlist, -1);
shader_reset();



