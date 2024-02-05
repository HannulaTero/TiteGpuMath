
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
	self.name = $"TiteGpuMatrix_{__counter++}"
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


	static Initialize = function(_width, _height, _params={})
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
		if (!surface_exists(self.surface))
		{
			self.surface = surface_create(self.size[0], self.size[1], self.format);
		}
		
		return self.surface;
	};
	
	
	static Texture = function()
	{
		return surface_get_texture(self.Surface());
	};


	static Bytes = function()
	{
		static __map = tite_gpu_mapping([
			surface_r8unorm,		1,
			surface_rg8unorm,		2,
			surface_rgba4unorm,		2,
			surface_rgba8unorm,		4,
			surface_r16float,		2,
			surface_r32float,		4,
			surface_rgba16float,	8,
			surface_rgba32float,	16
		]);
		var _dsize = __map[$ self.format] ?? 1;
		return _dsize * self.size[0] * self.size[1];
	};
	
	
	static BufferType = function()
	{
		static __map = tite_gpu_mapping([
			surface_r8unorm,		buffer_u8,
			surface_rg8unorm,		buffer_u8,
			surface_rgba4unorm,		buffer_u8,
			surface_rgba8unorm,		buffer_u8,
			surface_r16float,		buffer_f16,
			surface_r32float,		buffer_f32,
			surface_rgba16float,	buffer_f16,
			surface_rgba32float,	buffer_f32
		]);
		return __map[$ self.format] ?? buffer_u8;
	};

	
	static ToBuffer = function(_buffer=undefined, _offset=0)
	{
		if (_buffer == undefined)
		{
			_buffer = buffer_create(self.Bytes(), buffer_fixed, 1);
		}
		buffer_get_surface(_buffer, self.Surface(), _offset);
		buffer_seek(_buffer, buffer_seek_start, 0);
		return _buffer;
	};
	
	
	static FromBuffer = function(_buffer, _offset=0)
	{
		buffer_set_surface(_buffer, self.Surface(), _offset);
		buffer_seek(_buffer, buffer_seek_start, 0);
		return self;
	};
	
	
	static Copy = function(_src, _copyContent=false) 
	{
		self.size = variable_clone(_src.size);
		self.texel = variable_clone(_src.texel);
		self.count = _src.count;
		self.format = _src.format;
		if (_copyContent)
		{
			// feather ignore GM2023
			tite_gpu_begin();
			surface_copy(self.Surface(), 0, 0, _src.Surface());
			tite_gpu_end();
		}
		return self;
	};
	
	
	static Clone = function(_copyContent=false) 
	{
		return new TiteGpuMatrix(1, 1).Copy(self, _copyContent);
	};
	
	
	static Draw = function(_x=0, _y=0, _params={}) 
	{
		// Get the uniforms.
		static __shader = shdTiteGpuMatrix_visualize;
		static __uniFactor = shader_get_uniform(__shader, "uniFactor");
		
		// Get parameters for drawing.
		var _w = _params[$ "width"] ?? self.size[0];
		var _h = _params[$ "height"] ?? self.size[1];
			_w *= _params[$ "xscale"] ?? 1.0;
			_h *= _params[$ "yscale"] ?? 1.0;
		var _halign = _params[$ "halign"] ?? 0.0;
		var _valign = _params[$ "valign"] ?? 0.0;
			_x -= _w * _halign;
			_y -= _h * _valign;
			
		// Whether draw background.
		if (struct_exists(_params, "background"))
		{
			var _c = c_black;
			draw_rectangle_color(_x, _y, _x+_w, _y+_h, _c,_c,_c,_c, false);
		}
		
		// Whether remap values into. Useful for visualizing float textures.
		if (struct_exists(_params, "normalize"))
		{
			var _min = _params[$ "rangeMin"] ?? 0;
			var _max = _params[$ "rangeMax"] ?? 1;
			shader_set(__shader);
			shader_set_uniform_f(__uniFactor, _min, _max);
			draw_surface_stretched(self.Surface(), _x, _y, _w, _h);
			shader_reset();
		} else {
			draw_surface_stretched(self.Surface(), _x, _y, _w, _h);
		}
		
		// Whether draw outline.
		if (struct_exists(_params, "outline"))
		{
			var _c = c_white;
			draw_rectangle_color(_x, _y, _x+_w, _y+_h, _c,_c,_c,_c, true);
		}
		return self;
	};
	
	
	static Free = function() 
	{
		if (surface_exists(self.surface))
		{
			surface_free(self.surface);
		}
		return self;
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
		if (_rhs == undefined)
		{
			_rhs = _lhs;
			_lhs = self;
		}
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
		_src ??= self;
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


	static Dot = function(_lhs, _rhs=undefined, _axis=[1, 0]) 
	{
		if (_rhs == undefined)
		{
			_rhs = _lhs;
			_lhs = self;
		}
		return tite_gpu_math_dot(self, _lhs, _rhs, _axis);
	};

	static Clamp = function(_src=undefined, _min=0, _max=1) 
	{
		_src ??= self;
		return tite_gpu_math_clamp(self, _src, _min, _max);
	};
	
	
	static Mix = function(_lhs, _rhs=undefined, _rate=0.5) 
	{
		if (_rhs == undefined)
		{
			_rhs = _lhs;
			_lhs = self;
		}
		return tite_gpu_math_clamp(self, _lhs, _rhs, _rate);
	};


	static Offset = function(_src=undefined, _offset=undefined) 
	{
		_src ??= self;
		return tite_gpu_math_offset(self, _src, _offset);
	};


	static Scale = function(_src=undefined, _factor=undefined) 
	{
		_src ??= self;
		return tite_gpu_math_scale(self, _src, _factor);
	};
	
	
	static Normalize = function(_src=undefined, _min=0, _max=1)
	{
		return tite_gpu_math_normalize(self, _src, _min, _max);
	};	
	
	
	static Randomize = function(_min=0, _max=1, _seed=undefined)
	{
		return tite_gpu_math_randomize(self, _min, _max, _seed);
	};	

	
#endregion
// 
//==========================================================
}















