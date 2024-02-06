
/// @func	TiteGpuLut(_params);
/// @desc	Creates lookup table to be used with TiteGpu lookup operation.
/// @param	{Struct} _params
function TiteGpuLut(_params=undefined) : TiteGpuMatrix(undefined, undefined, undefined) constructor 
{
//==========================================================
//
#region VARIABLE DECLARATION.

	
	static __counter = 0;
	self.name = $"TiteGpuLut_{__counter++}";
	self.func = undefined;
	self.buffer = undefined;
	self.rangeMin = 0.0;
	self.rangeMax = 1.0;
	self.interpolate = true;
	self.Initialize(_params);


#endregion
// 
//==========================================================
//
#region USER HANDLE METHODS.


	/// @func	Initialize(_params);
	/// @desc	
	/// @param	{Struct}	_params
	/// @return	{Struct.TiteGpuLut}
	static Initialize = function(_params={}) 
	{
		static __super = TiteGpuMatrix.Initialize;
		
		// Initialize lookup table.
		self.func = _params[$ "func"];
		self.buffer = _params[$ "buffer"];
		self.rangeMin = _params[$ "rangeMin"] ?? 0.0;
		self.rangeMax = _params[$ "rangeMax"] ?? 1.0;
		
		// Initialize buffer in CPU side.
		var _width = _params[$ "width"] ?? ceil(abs(self.rangeMax - self.rangeMin));
		
		
		
		// Initialize the matrix part, which represents lut data in GPU.
		__super(_width, 1, _params);
		return self;
	};
	
	
	/// @func	Free();
	/// @desc	
	static Free = function()
	{
		static __super = TiteGpuMatrix.Free;
		
		__super();
		return self;
	}


#endregion
// 
//==========================================================
}