/// @desc DO THE CALCULATIONS

// Randomize
if (keyboard_check(vk_backspace))
{
	matPos.Randomize(room_width/2-64, room_width/2+64);
	matSpd.Randomize(-64.0, +64.0);
}

// Update positions and speed.
if (keyboard_check(vk_enter))
|| (keyboard_check_pressed(vk_space))
{
	matPos.Add(matSpd);			// Position update.
	matSpd.Scale(,0.995);		// Friction.
	matSpd.Offset(,[0,1,0,0]);	// Gravity.
	
	/*	
	Update vertex buffer.
		NOTE! This is bit of an hack.
		It would be much better to have pre-existing vertex buffer
		and in vertex shader move vertices based on texture.
		Problem is that Windows Export doesn't support Vertex Texture Fetching.
		There is DLL for that. To not include it here, I just recreate vertex buffer.
	*/
	if (vertexBuffer != undefined)
	{
		vertex_delete_buffer(vertexBuffer);
	}
	var _buff = matPos.ToBuffer();
	vertexBuffer = vertex_create_buffer_from_buffer(_buff, vertexFormat);
	buffer_delete(_buff);
}



