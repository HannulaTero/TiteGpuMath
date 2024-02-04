
/// @func	TiteGpuMatrix(_width, _height, _params);
/// @desc	Storage with methods to make surface act bit like a MxN Matrix.
/// @param	{Real}		_width
/// @param	{Real}		_height
/// @param	{Struct}	_params		Parameters for creating data. Check initialization method.
function TiteGpuMatrix(_width=1, _height=1, _params=undefined) constructor
{
//==========================================================
//
#region VARIABLE DECLARATION.


	static __counter = 0;
	self.name = $"FragData_{__counter++}"
	self.size = [1, 1];
	self.texel = [1.0, 1.0];
	self.count = 1;
	self.format = surface_rgba32float;
	self.surface = -1;
	
	if (_params != undefined) 
	{
		self.Initialize(_width, _height, _params);
	}
	
	
#endregion
// 
//==========================================================
//
#region USER HANDLE METHODS.


	static Initialize = function(_width, _height, _params)
	{
		// Optional parameters.
		self.name	= _params[$ "name"] ?? self.name;
		self.format	= _params[$ "format"] ?? self.format;
		
		// Set up the size.
		self.size[0] = clamp(ceil(_width), 1, 16384);
		self.size[1] = clamp(ceil(_height), 1, 16384);
		
		// Set up texel size.
		self.texel[0] = 1.0 / self.size[0];
		self.texel[1] = 1.0 / self.size[1];
		self.count = self.size[0] * self.size[1];
		
		// Give warning if size was not valid.
		if (self.size[0] != _width) || (self.size[1] != _height)
		{
			var _warning = $"[TiteGpuMatrix] Warning: ";
				_warning += $"non-valid size: [{_width}, {_height}], "
				_warning += $"changed into: [{self.size[0]}, {self.size[1]}], "
			show_debug_message(_warning);
		}
		
		return self;
	};
	
	
	static Surface = function()
	{
		// Make sure surface is correct shape.
		if (surface_exists(self.surface))
		{
			if (surface_get_width(self.surface) != self.size[0])
			|| (surface_get_height(self.surface) != self.size[1])
			|| (surface_get_format(self.surface) != self.format)
			{
				// Force recreation.
				surface_free(self.surface);
			}
		}
		
		// Make sure surface exists.
		if (surface_exists(self.surface))
		{
			self.surface = surface_create(self.size[0], self.size[1], self.format);
		}
		
		return self.surface;
	};
	
	
	static Texture = function()
	{
		return surface_get_texture(self.Surface());
	};

	
	static ToBuffer = function(_buffer, _offset)
	{
		buffer_get_surface(_buffer, self.Surface(), _offset);
		return self;
	};
	
	
	static FromBuffer = function(_buffer, _offset)
	{
		buffer_set_surface(_buffer, self.Surface(), _offset);
		return self;
	};
	
	
	static Copy = function(_src, _copyContent=false) 
	{
		self.size = variable_clone(_src.size);
		self.texel = variable_clone(_src.texel);
		self.count = _src.count;
		self.format = _src.format;
		self.surface = -1;
		if (_copyContent)
		{
			// feather ignore GM2023
			surface_copy(self.Surface(), 0, 0, _src.Surface());
		}
		return self;
	};
	
	
	static Clone = function(_copyContent=false) 
	{
		return new TiteGpuMatrix(1, 1).Copy(self, _copyContent);
	};
	
	
#endregion
// 
//==========================================================
//
#region MATH: LOOKUP TABLE.


	
#endregion
// 
//==========================================================
//
#region MATH: PIECEWISE BINARY OPERATIONS.
	
	
	// General binary operation.
	static Binary = function(_lhs, _rhs, _op) 
	{			
		return tite_gpu_math_binary(self, _lhs, _rhs, _op);	
	};
	
	// Binary operator handles.
	static Add		= function(_lhs, _rhs=undefined) { return Binary(_lhs, _rhs, shdTiteGpuMatrix_add); };
	static Distance	= function(_lhs, _rhs=undefined) { return Binary(_lhs, _rhs, shdTiteGpuMatrix_distance); };
	static Div		= function(_lhs, _rhs=undefined) { return Binary(_lhs, _rhs, shdTiteGpuMatrix_div); };
	static Max		= function(_lhs, _rhs=undefined) { return Binary(_lhs, _rhs, shdTiteGpuMatrix_max); };
	static Min		= function(_lhs, _rhs=undefined) { return Binary(_lhs, _rhs, shdTiteGpuMatrix_min); };
	static Mul		= function(_lhs, _rhs=undefined) { return Binary(_lhs, _rhs, shdTiteGpuMatrix_mul); };
	static Pow		= function(_lhs, _rhs=undefined) { return Binary(_lhs, _rhs, shdTiteGpuMatrix_pow); };
	static Sub		= function(_lhs, _rhs=undefined) { return Binary(_lhs, _rhs, shdTiteGpuMatrix_sub); };
	
	
#endregion
// 
//==========================================================
//
#region MATH: PIECEWISE UNARY OPERATIONS.
	
	
	// General unary operation.
	static Unary = function(_src, _op) 
	{
		return tite_gpu_math_unary(self, _src, _op);
	};
	
	// Unary operator handles.
	static Acos		= function(_lhs=undefined) { return Unary(_lhs, shdTiteGpuMatrix_acos); };
	static Asin		= function(_lhs=undefined) { return Unary(_lhs, shdTiteGpuMatrix_asin); };
	static Atan		= function(_lhs=undefined) { return Unary(_lhs, shdTiteGpuMatrix_atan); };
	static Cos		= function(_lhs=undefined) { return Unary(_lhs, shdTiteGpuMatrix_cos); };
	static Exp		= function(_lhs=undefined) { return Unary(_lhs, shdTiteGpuMatrix_exp); };
	static Log		= function(_lhs=undefined) { return Unary(_lhs, shdTiteGpuMatrix_log); };
	static Neg		= function(_lhs=undefined) { return Unary(_lhs, shdTiteGpuMatrix_neg); };
	static Relu		= function(_lhs=undefined) { return Unary(_lhs, shdTiteGpuMatrix_relu); };
	static Sigmoid	= function(_lhs=undefined) { return Unary(_lhs, shdTiteGpuMatrix_sigmoid); };
	static Sin		= function(_lhs=undefined) { return Unary(_lhs, shdTiteGpuMatrix_sin); };
	static Sqr		= function(_lhs=undefined) { return Unary(_lhs, shdTiteGpuMatrix_sqr); };
	static Sqrt		= function(_lhs=undefined) { return Unary(_lhs, shdTiteGpuMatrix_sqrt); };
	static Tan		= function(_lhs=undefined) { return Unary(_lhs, shdTiteGpuMatrix_tan); };
	static Tanh		= function(_lhs=undefined) { return Unary(_lhs, shdTiteGpuMatrix_tanh); };
	
	
#endregion
// 
//==========================================================
//
#region MATH: OTHER PIECEWISE OPERATIONS.


	static Dot = function(_lhs, _rhs, _axis=[1, 0]) 
	{
		return tite_gpu_math_dot(self, _lhs, _rhs, _axis);
	};

	static Clamp = function(_src, _min, _max) 
	{
		return tite_gpu_math_clamp(self, _src, _min, _max);
	};
	
	
	static Mix = function(_lhs, _rhs, _rate) 
	{
		return tite_gpu_math_clamp(self, _lhs, _rhs, _rate);
	};


	static Offset = function(_src, _offset) 
	{
		return tite_gpu_math_offset(self, _src, _offset);
	};


	static Scale = function(_src, _factor) 
	{
		return tite_gpu_math_scale(self, _src, _factor);
	};
	
	
	static Randomize = function(_min=0, _max=1, _seed=undefined)
	{
		return tite_gpu_math_randomize(self, _min, _max, _seed);
	};	

	
#endregion
// 
//==========================================================
}














