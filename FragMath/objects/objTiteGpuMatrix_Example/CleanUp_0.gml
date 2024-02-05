/// @desc DESTROY DATA

matPos.Free();
matSpd.Free();
vertex_format_delete(vertexFormat);
if (vertexBuffer != undefined) 
{
	vertex_delete_buffer(vertexBuffer);
}




