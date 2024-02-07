/// @desc RECREATE VERTEX BUFFER

if (keyboard_check(vk_left))
|| (keyboard_check(vk_right))
|| (keyboard_check(vk_enter))
|| (keyboard_check(ord("R")))
|| (keyboard_check_pressed(vk_up))
|| (keyboard_check_pressed(vk_down))
|| (keyboard_check_pressed(vk_space))
{
	if (vertexBuffer != undefined)
		vertex_delete_buffer(vertexBuffer);
	
	with(obj_tite_example_particles_calculate)
	{
		var _buff = matPos.ToBuffer();
		buffer_seek(_buff, buffer_seek_start, 0);
		other.vertexBuffer = vertex_create_buffer_from_buffer(_buff, other.vertexFormat);
		vertex_freeze(other.vertexBuffer);
		buffer_delete(_buff);
	}
}






















































