/// @desc
show_debug_overlay(true, true);
tite_message($"swizzle compiled : {shader_is_compiled(tite_op_swizzle)}");
// Allow resizing for more.
dimension = 256;
		
// The matrix data, used for simple particles.
matPos = new TiteData(dimension, dimension, { name: "Position" });
matSpd = new TiteData(dimension, dimension, { name: "Speed" });
lutSin = new TiteDataLut({
	width: 256,
	rangeMin: -pi,
	rangeMax: +pi,
	func: function(_lhs) { return sin(_lhs); }
});

self.context = {
	pos : undefined,
	spd : undefined,
	dimension: dimension
};
tite_execute(self.context, @"
	pos = data<f32>(dimension, dimension);
	spd = data<f32>(dimension, dimension);
");


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



