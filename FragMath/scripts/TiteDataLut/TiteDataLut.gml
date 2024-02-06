
/// @func	TiteMatrixLut(_params);
/// @desc	Creates lookup table to be used with TiteGpu lookup operation.
/// @param	{Struct} _params
function TiteMatrixLut(_params=undefined) : TiteData() constructor 
{
//==========================================================
//
#region VARIABLE DECLARATION.

	
	static __counter = 0;
	self.name = $"TiteMatrixLut_{__counter++}";
	self.func = undefined;
	self.buffer = buffer_create(1, buffer_fixed, 1);
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
	/// @desc	Initializes lookup table parameters.
	/// @param	{Struct}	_params
	/// @return	{Struct.TiteMatrixLut}
	static Initialize = function(_params={}) 
	{
		static __super = TiteData.Initialize;
		
		// Initialize lookup table.
		self.func = _params[$ "func"] ?? function(_lhs) { return _lhs; };
		self.rangeMin = _params[$ "rangeMin"] ?? 0.0;
		self.rangeMax = _params[$ "rangeMax"] ?? 1.0;
		
		// Initialize the matrix part, which represents lut data in GPU.
		var _width = _params[$ "width"] ?? ceil(abs(self.rangeMax - self.rangeMin));
		__super(_width, 1, _params);
		
		// Initialize buffer in CPU side.
		var _div = 1.0 / (self.count - 1);
		var _dsize = tite_format_bytes(self.format);
		var _dtype = tite_format_buffer_dtype(self.format);
		var _components = tite_format_components(self.format);
		buffer_resize(self.buffer, _dsize * self.count);
		buffer_seek(self.buffer, buffer_seek_start, 0);
		for(var i = 0.0; i < self.count; i++)
		{
			var _lhs = lerp(self.rangeMin, self.rangeMax, i * _div);
			var _out = self.func(_lhs);
			repeat(_components) 
			{
				buffer_write(self.buffer, _dtype, _out);
			}
		}
		
		return self;
	};
	
	
	/// @func	Surface();
	/// @desc	Verifies surface exists, and has correct content for lookup.
	/// @return	{Id.Surface}
	static Surface = function()
	{
		static __super = TiteData.Surface;
		var _surf = __super();
		self.FromBuffer(self.buffer);
		return _surf;
	};
	
	
	/// @func	Free();
	/// @desc	
	static Free = function()
	{
		static __super = TiteData.Free;
		__super();
		buffer_delete(self.buffer);
		return self;
	};


#endregion
// 
//==========================================================
}