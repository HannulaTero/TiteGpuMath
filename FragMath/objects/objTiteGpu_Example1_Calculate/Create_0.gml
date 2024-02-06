/// @desc
show_debug_overlay(true, true);

// Allow resizing for more.
dimension = 256;
		
// The matrix data, used for simple particles.
matPos = new TiteGpuMatrix(dimension, dimension, { name: "Position" });
matSpd = new TiteGpuMatrix(dimension, dimension, { name: "Speed" });


// Helper methods.
Reset = function() 
{
	var _len = 64.0;
	var _min = room_width * 0.5 - _len;
	var _max = room_width * 0.5 + _len;
	matPos.Randomize(_min, _max);
	matSpd.Randomize(-16.0, +16.0);	// Random direction.
	matSpd.Offset(,[0.0, -12.0]);	// Upward momentum.
	matPos.Cumulative().Randomize(-1.0, +1.0);
	matSpd.Cumulative().Randomize(-1.0, +1.0);
};



