/// @desc DESTROY VERTEX BUFFER & FORMAT
if (vertexBuffer != undefined) 
{
	vertex_delete_buffer(vertexBuffer);
}
if (os_browser != browser_not_a_browser)
{
	vertex_format_delete(vertexFormat);
}
