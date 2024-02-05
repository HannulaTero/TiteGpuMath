
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


	/// @func	Initialize(_width, _height, _params);
	/// @desc	Set size, format and name of matrix.
	/// @param	{Real}		_width
	/// @param	{Real}		_height
	/// @param	{Struct}	_params		[Optional] format and name.
	/// @return	{Struct.TiteGpuMatrix}
	static Initialize = function(_width, _height, _params={})
	{
		// Optional parameters.
		self.format	= _params[$ "format"] ?? self.format;
		self.name	= _params[$ "name"] ?? self.name;
		
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
	

	/// @func	Surface();
	/// @desc	Return surface which is the data of this matrix.
	/// @return {Id.Surface}
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
	
	
	/// @func	Texture();
	/// @desc	Return texture for surface.
	/// @return {Pointer.Texture}
	static Texture = function()
	{
		return surface_get_texture(self.Surface());
	};


	/// @func	Bytes();
	/// @desc	Returns how many bytes the matrix requires to be put into buffer.
	/// @return {Real}
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
	
	
	/// @func	BufferType();
	/// @desc	Returns what buffer datatype should be used to read values.
	/// @return {Constant.BufferDataType}
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

	
	/// @func	ToBuffer(_buffer, _offset);
	/// @desc	Put contents of matrix into given buffer.
	/// @param	{Id.Buffer}	_buffer		If not given, one is created for you. 
	/// @param	{Real}		_offset 
	/// @return {Id.Buffer}
	static ToBuffer = function(_buffer=undefined, _offset=0)
	{
		_buffer ??= buffer_create(self.Bytes(), buffer_fixed, 1);
		buffer_get_surface(_buffer, self.Surface(), _offset);
		buffer_seek(_buffer, buffer_seek_start, 0);
		return _buffer;
	};
	
	
	/// @func	FromBuffer(_buffer, _offset);
	/// @desc	Put contents of given buffer into matrix.
	/// @param	{Id.Buffer}	_buffer
	/// @param	{Real}		_offset 
	/// @return {Struct.TiteGpuMatrix}
	static FromBuffer = function(_buffer, _offset=0)
	{
		buffer_set_surface(_buffer, self.Surface(), _offset);
		buffer_seek(_buffer, buffer_seek_start, 0);
		return self;
	};
	
	
	/// @func	Copy(_src, _copyContent);
	/// @desc	Copies structure from other matrix, optionally also copy the contents.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @param	{Bool}					_copyContent
	/// @return {Struct.TiteGpuMatrix}
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
	
	
	/// @func	Clone(_copyContent);
	/// @desc	Creates clone of matrix, optionally also copy the contents.
	/// @param	{Bool}					_copyContent
	/// @return {Struct.TiteGpuMatrix}
	static Clone = function(_copyContent=false) 
	{
		return new TiteGpuMatrix(1, 1).Copy(self, _copyContent);
	};
	
	
	/// @func	Draw(_x, _y, _params);
	/// @desc	Draws surface with given parameters.
	/// @param	{Real}		_x
	/// @param	{Real}		_y
	/// @param	{Struct}	_params	[Optional]
	/// @return {Struct.TiteGpuMatrix}
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
	

	/// @func	Free();
	/// @desc	Frees the surface in this matrix, after matrix can be let go.
	/// @return {Struct.TiteGpuMatrix}
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
#region MATH: SETTINGS
	
	
	/// @func	Cumulative();
	/// @desc	Set next calculation as cumulative result.
	/// @return {Struct.TiteGpuMatrix}
	static Cumulative = function()
	{
		tite_gpu_set_cumulative(true);
		return self;
	};
	
	
	/// @func	Interpolate();
	/// @desc	Set next calculation inputs interpolative (LUT).
	/// @return {Struct.TiteGpuMatrix}
	static Interpolate = function()
	{
		tite_gpu_set_interpolate(true);
		return self;
	};
	
	
	/// @func	Repetive();
	/// @desc	Set next calculation inputs repetive (LUT).
	/// @return {Struct.TiteGpuMatrix}
	static Repetive = function()
	{
		tite_gpu_set_repetive(true);
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
	
	
	/// @func	Binary(_lhs, _rhs, _op);
	/// @desc	General piecewise binary operator executer.
	/// @param	{Struct.TiteGpuMatrix}	_lhs
	/// @param	{Struct.TiteGpuMatrix}	_rhs
	/// @param	{Asset.GMShader}		_op		TiteGpu shader
	/// @return {Struct.TiteGpuMatrix}
	static Binary = function(_lhs, _rhs, _op) 
	{
		if (_rhs == undefined)
		{
			_rhs = _lhs;
			_lhs = self;
		}
		return tite_gpu_math_binary(self, _lhs, _rhs, _op);	
	};
	
	
	/// @func	Add(_lhs, _rhs);
	/// @desc	Does piecewise addition between two matrices.
	/// @param	{Struct.TiteGpuMatrix}	_lhs
	/// @param	{Struct.TiteGpuMatrix}	_rhs
	/// @return {Struct.TiteGpuMatrix}
	static Add = function(_lhs, _rhs=undefined) 
	{ 
		return Binary(_lhs, _rhs, shdTiteGpuMatrix_add); 
	};
	
	
	/// @func	Distance(_lhs, _rhs);
	/// @desc	Calculates piecewise distance values. More useful with vec4 values.
	/// @param	{Struct.TiteGpuMatrix}	_lhs
	/// @param	{Struct.TiteGpuMatrix}	_rhs
	/// @return {Struct.TiteGpuMatrix}
	static Distance	= function(_lhs, _rhs=undefined) 
	{ 
		return Binary(_lhs, _rhs, shdTiteGpuMatrix_distance); 
	};
	
	
	/// @func	Div(_lhs, _rhs);
	/// @desc	Does piecewise division between two matrices.
	/// @param	{Struct.TiteGpuMatrix}	_lhs
	/// @param	{Struct.TiteGpuMatrix}	_rhs
	/// @return {Struct.TiteGpuMatrix}
	static Div = function(_lhs, _rhs=undefined) 
	{ 
		return Binary(_lhs, _rhs, shdTiteGpuMatrix_div); 
	};
	
	
	/// @func	Max(_lhs, _rhs);
	/// @desc	Does piecewise maximum between two matrices.
	/// @param	{Struct.TiteGpuMatrix}	_lhs
	/// @param	{Struct.TiteGpuMatrix}	_rhs
	/// @return {Struct.TiteGpuMatrix}
	static Max = function(_lhs, _rhs=undefined) 
	{ 
		return Binary(_lhs, _rhs, shdTiteGpuMatrix_max); 
	};
	
	
	/// @func	Min(_lhs, _rhs);
	/// @desc	Does piecewise minimum between two matrices.
	/// @param	{Struct.TiteGpuMatrix}	_lhs
	/// @param	{Struct.TiteGpuMatrix}	_rhs
	/// @return {Struct.TiteGpuMatrix}
	static Min = function(_lhs, _rhs=undefined) 
	{ 
		return Binary(_lhs, _rhs, shdTiteGpuMatrix_min); 
	};
	
	
	/// @func	Mul(_lhs, _rhs);
	/// @desc	Does piecewise mupliplication between two matrices.
	/// @param	{Struct.TiteGpuMatrix}	_lhs
	/// @param	{Struct.TiteGpuMatrix}	_rhs
	/// @return {Struct.TiteGpuMatrix}
	static Mul = function(_lhs, _rhs=undefined) 
	{ 
		return Binary(_lhs, _rhs, shdTiteGpuMatrix_mul); 
	};
	
	
	/// @func	Pow(_lhs, _rhs);
	/// @desc	Does piecewise power operation between two matrices.
	/// @param	{Struct.TiteGpuMatrix}	_lhs
	/// @param	{Struct.TiteGpuMatrix}	_rhs
	/// @return {Struct.TiteGpuMatrix}
	static Pow = function(_lhs, _rhs=undefined) 
	{ 
		return Binary(_lhs, _rhs, shdTiteGpuMatrix_pow); 
	};
	
	
	/// @func	Root(_lhs, _rhs);
	/// @desc	Does piecewise root operation with two matrices.
	/// @param	{Struct.TiteGpuMatrix}	_lhs
	/// @param	{Struct.TiteGpuMatrix}	_rhs
	/// @return {Struct.TiteGpuMatrix}
	static Root = function(_lhs, _rhs=undefined) 
	{ 
		return Binary(_lhs, _rhs, shdTiteGpuMatrix_root); 
	};
	
	
	/// @func	Sub(_lhs, _rhs);
	/// @desc	Does piecewise subtraction between two matrices.
	/// @param	{Struct.TiteGpuMatrix}	_lhs
	/// @param	{Struct.TiteGpuMatrix}	_rhs
	/// @return {Struct.TiteGpuMatrix}
	static Sub = function(_lhs, _rhs=undefined) 
	{ 
		return Binary(_lhs, _rhs, shdTiteGpuMatrix_sub); 
	};
	
	
#endregion
// 
//==========================================================
//
#region MATH: PIECEWISE UNARY OPERATIONS.
	
	
	/// @func	Unary(_src, _op);
	/// @desc	General unary operator executer.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @param	{Asset.GMShader}		_op		TiteGpu shader
	/// @return {Struct.TiteGpuMatrix}
	static Unary = function(_src, _op) 
	{
		_src ??= self;
		return tite_gpu_math_unary(self, _src, _op);
	};
	
	
	/// @func	Acos(_src);
	/// @desc	Does piecewise trigonometric arc cosine operation.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @return {Struct.TiteGpuMatrix}
	static Acos = function(_src=undefined) 
	{
		return Unary(_src, shdTiteGpuMatrix_acos); 
	};
	
	
	/// @func	Asin(_src);
	/// @desc	Does piecewise trigonometric arc sine operation.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @return {Struct.TiteGpuMatrix}
	static Asin = function(_src=undefined) 
	{
		return Unary(_src, shdTiteGpuMatrix_asin); 
	};
	
	
	/// @func	Atan(_src);
	/// @desc	Does piecewise trigonometric arc tangent operation.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @return {Struct.TiteGpuMatrix}
	static Atan = function(_src=undefined) 
	{
		return Unary(_src, shdTiteGpuMatrix_atan); 
	};
	
	
	/// @func	Cos(_src);
	/// @desc	Does piecewise trigonometric cosine operation.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @return {Struct.TiteGpuMatrix}
	static Cos = function(_src=undefined) 
	{
		return Unary(_src, shdTiteGpuMatrix_cos); 
	};
	
	
	/// @func	Exp(_src);
	/// @desc	Does piecewise power(euler, n) operation.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @return {Struct.TiteGpuMatrix}
	static Exp = function(_src=undefined) 
	{
		return Unary(_src, shdTiteGpuMatrix_exp); 
	};
	
	
	/// @func	Log(_src);
	/// @desc	Does piecewise logarithmic operation.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @return {Struct.TiteGpuMatrix}
	static Log = function(_src=undefined) 
	{
		return Unary(_src, shdTiteGpuMatrix_log); 
	};
	
	
	/// @func	Neg(_src);
	/// @desc	Does piecewise negation operation.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @return {Struct.TiteGpuMatrix}
	static Neg = function(_src=undefined) 
	{
		return Unary(_src, shdTiteGpuMatrix_neg); 
	};
	
	
	/// @func	Relu(_src);
	/// @desc	Does piecewise rectified linear unit operation: max(0, x).
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @return {Struct.TiteGpuMatrix}
	static Relu = function(_src=undefined) 
	{
		return Unary(_src, shdTiteGpuMatrix_relu); 
	};
	
	
	/// @func	Sigmoid(_src);
	/// @desc	Does piecewise sigmoid operation.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @return {Struct.TiteGpuMatrix}
	static Sigmoid = function(_src=undefined) 
	{
		return Unary(_src, shdTiteGpuMatrix_sigmoid); 
	};
	
	
	/// @func	Sin(_src);
	/// @desc	Does piecewise trigonometric sine operation.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @return {Struct.TiteGpuMatrix}
	static Sin = function(_src=undefined) 
	{
		return Unary(_src, shdTiteGpuMatrix_sin); 
	};
	
	
	/// @func	Sqr(_src);
	/// @desc	Does piecewise squaring operation.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @return {Struct.TiteGpuMatrix}
	static Sqr = function(_src=undefined) 
	{
		return Unary(_src, shdTiteGpuMatrix_sqr); 
	};
	
	
	/// @func	Sqrt(_src);
	/// @desc	Does piecewise square root operation.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @return {Struct.TiteGpuMatrix}
	static Sqrt = function(_src=undefined) 
	{ 
		return Unary(_src, shdTiteGpuMatrix_sqrt); 
	};
	
	
	/// @func	Tan(_src);
	/// @desc	Does piecewise trigonometric tangent operation.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @return {Struct.TiteGpuMatrix}
	static Tan = function(_src=undefined) 
	{ 
		return Unary(_src, shdTiteGpuMatrix_tan); 
	};
	
	
	/// @func	Tanh(_src);
	/// @desc	Does piecewise trigonometric hyperbolic tangent operation.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @return {Struct.TiteGpuMatrix}
	static Tanh = function(_src=undefined) 
	{ 
		return Unary(_src, shdTiteGpuMatrix_tanh); 
	};
	
	
#endregion
// 
//==========================================================
//
#region MATH: OTHER OPERATIONS.


	/// @func	Dot(_lhs, _rhs, _axis);
	/// @desc	Matrix dot product, sumreduces given axis.
	/// @param	{Struct.TiteGpuMatrix}	_lhs
	/// @param	{Struct.TiteGpuMatrix}	_rhs
	/// @param	{Array<Real>}			_axis
	/// @return {Struct.TiteGpuMatrix}
	static Dot = function(_lhs=undefined, _rhs=undefined, _axis=[1, 0]) 
	{
		_lhs ??= self;
		_rhs ??= self;
		return tite_gpu_math_dot(self, _lhs, _rhs, _axis);
	};


	/// @func	Clamp(_src, _min, _max);
	/// @desc	Clamps values to given range.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @param	{Real}					_min
	/// @param	{Real}					_max
	/// @return {Struct.TiteGpuMatrix}
	static Clamp = function(_src=undefined, _min=0, _max=1) 
	{
		_src ??= self;
		return tite_gpu_math_clamp(self, _src, _min, _max);
	};
	
	
	/// @func	Mix(_lhs, _rhs, _rate);
	/// @desc	Lerps two matrices with given rate.
	/// @param	{Struct.TiteGpuMatrix}	_lhs
	/// @param	{Struct.TiteGpuMatrix}	_rhs
	/// @param	{Real}					_rate
	/// @return {Struct.TiteGpuMatrix}
	static Mix = function(_lhs=undefined, _rhs=undefined, _rate=0.5) 
	{
		_lhs ??= self;
		_rhs ??= self;
		return tite_gpu_math_mix(self, _lhs, _rhs, _rate);
	};


	/// @func	Offset(_src, _offset);
	/// @desc	Adds offset to given matrix.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @param	{Any}					_offset	Single value, or 4 item array.
	/// @return {Struct.TiteGpuMatrix}
	static Offset = function(_src=undefined, _offset=undefined) 
	{
		_src ??= self;
		return tite_gpu_math_offset(self, _src, _offset);
	};


	/// @func	Scale(_src, _factor);
	/// @desc	Scales values of given matrix.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @param	{Any}					_factor	Single value, or 4 item array.
	/// @return {Struct.TiteGpuMatrix}
	static Scale = function(_src=undefined, _factor=undefined) 
	{
		_src ??= self;
		return tite_gpu_math_scale(self, _src, _factor);
	};
	

	/// @func	Normalize(_src, _min, _max);
	/// @desc	Normalizes matrix to given range, but does not clamp if it exceeds.
	/// @param	{Struct.TiteGpuMatrix}	_src
	/// @param	{Any}					_min
	/// @param	{Any}					_max
	/// @return {Struct.TiteGpuMatrix}
	static Normalize = function(_src=undefined, _min=undefined, _max=undefined)
	{
		_src ??= self;
		return tite_gpu_math_normalize(self, _src, _min, _max);
	};	


	/// @func	Set(_values);
	/// @desc	Set all matrix values to given value
	/// @param	{Any}	_values		Single value or 4 item array.
	/// @return {Struct.TiteGpuMatrix}
	static Set = function(_values=undefined) 
	{
		return tite_gpu_math_set(self, _values);
	};


	/// @func	Randomize(_min, _max, _seed);
	/// @desc	Randomizes matrix.
	/// @param	{Any}	_min	Single value or 4 item array.
	/// @param	{Any}	_max	Single value or 4 item array.
	/// @param	{Real}	_seed
	/// @return {Struct.TiteGpuMatrix}
	static Randomize = function(_min=undefined, _max=undefined, _seed=undefined)
	{
		return tite_gpu_math_randomize(self, _min, _max, _seed);
	};	

	
#endregion
// 
//==========================================================
}















