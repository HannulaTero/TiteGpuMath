/// @desc VISUALIZE PARTICLES

with(objTiteGpuMatrix_Example1)
{
	// Prepare.
	var _vbuff = other.vertexBuffer;
	var _shader = shdTiteGpuMatrix_Example1_VTF;
	var _sampler = shader_get_sampler_index(_shader, "texA");
	var _uniTexelA = shader_get_uniform(_shader, "uniTexelA");
	var _uniOffset = shader_get_uniform(_shader, "uniOffset");
	
	// Submit vertex buffer.
	shader_set(_shader);
	texture_set_stage(_sampler, matPos.Texture());
	shader_set_uniform_f_array(_uniTexelA, matPos.texel);
	for(var i = 0; i < dimension; i += other.dimension) 
	{
		for(var j = 0; j < dimension; j += other.dimension) 
		{
			shader_set_uniform_f(_uniOffset, i, j);
			vertex_submit(_vbuff, pr_trianglelist, -1);
		}
	}
	
	shader_reset();
}






