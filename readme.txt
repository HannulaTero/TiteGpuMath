========================================================

TITE GPU MATH LIBRARY
	Written for Cookbook jam.
	By Tero Hannula
	
========================================================

HOW TO USE

1)	Create data with given size. With struct you can give optional parameters.
		data = new TiteData(256, 256); // Creates gpu data block with default parameters.
		
2)	Do calculations in any of Draw-events, as this uses shaders and surfaces. 
	You can use either method-functions, or script functions directly.
		data.Randomize(-16.0, +16.0);		// Randomizes contents to be between -16 and +16.
		tite_randomize(data, -16.0, +16.0);	// Does same.

3)	To set values into gpu, use FromBuffer-method.
		data.FromBuffer(buffer); // Puts contents of buffer into data.

4)	Get results from data into to used in GML, use ToBuffer-method.
		data.ToBuffer(buffer); // Puts contents of gpu into buffer.

5)	Destroy gpu datablock when you don't use it anymore.
		data.Free(); // Frees the GPU data. If you still use this handle, data is recreated.


========================================================

GENERAL CONSIDERATIONS & INFO

Different GPUs can have differing behaviour, and they might not support same accuracies.

Calculations must happen in the GameMaker's Draw-events, 
because calculations are just rendering, and drawing doesn't work in other events. 

Operation methods will take inputs, and store results in callee.

In-place operations make temporal surface, which is cleaned afterwards. 
	- Reason for this, is that you can't use surface as both source and destination.



========================================================