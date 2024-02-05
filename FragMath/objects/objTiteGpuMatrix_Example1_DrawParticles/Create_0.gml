/// @desc WINDOWS RENDERER
/*	
	NOTE! This is bit of an hack.
	It would be much better to have pre-existing vertex buffer
	and in vertex shader move vertices based on texture.
	Problem is that Windows Export doesn't support Vertex Texture Fetching.
	There is DLL for that. To not include it here, I just recreate vertex buffer.
*/

depth = -1000;
vertexBuffer = undefined;
vertex_format_begin();
vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);
vertexFormat = vertex_format_end();


// Change to HTML5 renderer.
// HTML5 supports VTF, so that's smarter choice.
if (os_browser != browser_not_a_browser)
{
	instance_create_depth(0, 0, 0, objTiteGpuMatrix_Example1_DrawParticles_VTF);
	instance_destroy();
	exit;
}


