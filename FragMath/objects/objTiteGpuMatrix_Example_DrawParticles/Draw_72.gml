/// @desc UPDATE VERTEX BUFFER

if (keyboard_check(vk_enter))
|| (keyboard_check(vk_backspace))
|| (keyboard_check_pressed(vk_space))
{
	if (vertexBuffer != undefined)
	{
		vertex_delete_buffer(vertexBuffer);
	}
	with(objTiteGpuMatrix_Example)
	{
		var _buff = matPos.ToBuffer();
		buffer_seek(_buff, buffer_seek_start, 0);
		other.vertexBuffer = vertex_create_buffer_from_buffer(_buff, other.vertexFormat);
		buffer_delete(_buff);
	}
}






















































