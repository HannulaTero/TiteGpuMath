/// @desc CREATE VERTEX BUFFER

depth = -200;
dimension = 128;


// Vertex format.
vertex_format_begin();
vertex_format_add_custom(vertex_type_float2, vertex_usage_texcoord);
vertex_format_add_custom(vertex_type_float2, vertex_usage_texcoord);
vertexFormat = vertex_format_end();


// Create new vertex buffer.
// I think in HTML5 you can't use pr_pointlist, so using quads instead.
vertexBuffer = vertex_create_buffer();
vertex_begin(vertexBuffer, vertexFormat);
for(var i = 0; i < dimension; i++) 
{
	for(var j = 0; j < dimension; j++) 
	{
		// 1. triangle
		vertex_float2(vertexBuffer, i, j); vertex_float2(vertexBuffer, 0, 0);
		vertex_float2(vertexBuffer, i, j); vertex_float2(vertexBuffer, 1, 0);
		vertex_float2(vertexBuffer, i, j); vertex_float2(vertexBuffer, 1, 1);
	
		// 2. triangle
		vertex_float2(vertexBuffer, i, j); vertex_float2(vertexBuffer, 1, 0);
		vertex_float2(vertexBuffer, i, j); vertex_float2(vertexBuffer, 0, 1);
		vertex_float2(vertexBuffer, i, j); vertex_float2(vertexBuffer, 0, 0);
	}
}
vertex_end(vertexBuffer);
vertex_freeze(vertexBuffer);
