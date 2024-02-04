
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
	self.name		= $"FragData_{__counter++}"
	self.size		= [1, 1];
	self.texel		= [1.0, 1.0];
	self.count		= 1;
	self.format		= surface_rgba32float;
	self.surface	= -1;
	
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
	
	
	static Match = function(_lhs)
	{
		return ((self.size[0] == _lhs.size[0]) && ((self.size[1] == _lhs.size[1])))
			|| ((self.size[0] == 1) && (self.size[1] == 1))	 // Allow scalar.
			|| ((_lhs.size[0] == 1) && (_lhs.size[1] == 1)); // 
	};
	
	
	static Copy = function(_src, _copyContent=false) 
	{
		self.size		= variable_clone(_src.size);
		self.texel		= variable_clone(_src.texel);
		self.count		= _src.count;
		self.format		= _src.format;
		self.surface	= -1;
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
#region MATH: MATRIX DOT PRODUCT.


	static Dot = function(_lhs, _rhs, _axis=[1, 0]) 
	{
		// Trying to do in-place operation.
		if (self == _lhs) || (self == _rhs)
		{
			return self.GpuInplace(self, self.Dot, [_lhs, _rhs, _axis]);
		}
		
		// Check dimensionality match.
		if (_lhs.size[_axis[0]] != _rhs.size[_axis[1]])
		{
			throw($"Dot product: target axis do not match.");
		}
		
		// Select axis which stay, and which are stepped upon.
		var _startA = [real(_axis[0] == 1), real(_axis[0] == 0)];
		var _startB = [real(_axis[1] == 1), real(_axis[1] == 0)];
		var _stepsA = [_startA[0] ? 0.0 : _lhs.texel[0], _startA[1] ? 0.0 : _lhs.texel[1]];
		var _stepsB = [_startB[2] ? 0.0 : _rhs.texel[0], _startB[1] ? 0.0 : _rhs.texel[1]];
		var _iterations = _lhs.shape[_axis[0]];
	
		// Do the computation.
		self.GpuBegin();
		self.GpuShader(shdTiteGpuMatrix_dot);
		self.GpuFloatN("uniTexelA", _lhs.texel);
		self.GpuFloatN("uniTexelB", _rhs.texel);
		self.GpuFloatN("uniStartA", _startA);
		self.GpuFloatN("uniStartB", _startB);
		self.GpuFloatN("uniStepsA", _stepsA);
		self.GpuFloatN("uniStepsB", _stepsB);
		self.GpuFloatN("uniIterations", _iterations);
		self.GpuSample("texA", _lhs);
		self.GpuSample("texB", _rhs);
		self.GpuTarget(self);
		self.GpuRender();
		self.GpuEnd();
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
		// Trying to do in-place operation.
		if (self == _lhs) || (self == _rhs)
		{
			return self.GpuInplace(self, self.Binary, [_lhs, _rhs, _op]);
		}

		// Check dimensionality match.
		if (!self.Match(_lhs)) || (!self.Match(_rhs)) 
		{
			throw($"Piecewise math: Output and Inputs dimensions do not match.");
		}
		
		// Do the computation.
		self.GpuBegin();
		self.GpuShader(_op);
		self.GpuFloatN("texelA", _lhs.texel);
		self.GpuFloatN("texelB", _rhs.texel);
		self.GpuSample("texA", _lhs);
		self.GpuSample("texB", _rhs);
		self.GpuTarget(self);
		self.GpuRender();
		self.GpuEnd();
		return self;
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
	static Unary = function(_lhs, _op) 
	{
		// Trying to do in-place operation.
		if (self == _lhs)
		{
			return self.GpuInplace(self, self.Unary, [_lhs, _op]);
		}

		// Check dimensionality match.
		if (!self.Match(_lhs)) 
		{
			throw($"Piecewise math: Output and Input dimensions do not match.");
		}
		
		// Do the computation.
		self.GpuBegin();
		self.GpuShader(_op);
		self.GpuFloatN("texelA", _lhs.texel);
		self.GpuSample("texA", _lhs);
		self.GpuTarget(self);
		self.GpuRender();
		self.GpuEnd();
		return self;
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


	static Clamp = function(_lhs, _min, _max) 
	{
		// Trying to do in-place operation.
		if (self == _lhs)
		{
			return self.GpuInplace(self, self.Clamp, [_lhs, _min, _max]);
		}

		// Check dimensionality match.
		if (!self.Match(_lhs)) 
		{
			throw($"Piecewise math: Output and Input dimensions do not match.");
		}
		
		// Do the computation.
		self.GpuBegin();
		self.GpuShader(shdTiteGpuMatrix_clamp);
		self.GpuFloatN("texelA", _lhs.texel);
		self.GpuFloat2("uniRange", _min, _max);
		self.GpuSample("texA", _lhs);
		self.GpuTarget(self);
		self.GpuRender();
		self.GpuEnd();
		return self;
	};
	
	
	static Mix = function(_lhs, _rhs, _rate) 
	{
		// Trying to do in-place operation.
		if (self == _lhs) || (self == _rhs)
		{
			return self.GpuInplace(self, self.Mix, [_lhs, _rhs, _rate]);
		}

		// Check dimensionality match.
		if (!self.Match(_lhs)) || (!self.Match(_rhs))
		{
			throw($"Piecewise math: Output and Input dimensions do not match.");
		}
		
		// Do the computation.
		self.GpuBegin();
		self.GpuShader(shdTiteGpuMatrix_mix);
		self.GpuFloatN("texelA", _lhs.texel);
		self.GpuFloatN("texelB", _rhs.texel);
		self.GpuFloat1("uniRate", _rate);
		self.GpuSample("texA", _lhs);
		self.GpuSample("texB", _rhs);
		self.GpuTarget(self);
		self.GpuRender();
		self.GpuEnd();
		return self;
	};


	static Offset = function(_lhs, _offset) 
	{
		// Trying to do in-place operation.
		if (self == _lhs)
		{
			return self.GpuInplace(self, self.Offset, [_lhs, _offset]);
		}

		// Check dimensionality match.
		if (!self.Match(_lhs)) 
		{
			throw($"Piecewise math: Output and Input dimensions do not match.");
		}
		
		// Do the computation.
		self.GpuBegin();
		self.GpuShader(shdTiteGpuMatrix_offset);
		self.GpuFloatN("texelA", _lhs.texel);
		self.GpuFloat1("uniOffset", _offset);
		self.GpuSample("texA", _lhs);
		self.GpuTarget(self);
		self.GpuRender();
		self.GpuEnd();
		return self;
	};


	static Scale = function(_lhs, _factor) 
	{
		// Trying to do in-place operation.
		if (self == _lhs)
		{
			return self.GpuInplace(self, self.Scale, [_lhs, _factor]);
		}

		// Check dimensionality match.
		if (!self.Match(_lhs)) 
		{
			throw($"Piecewise math: Output and Input dimensions do not match.");
		}
		
		// Do the computation.
		self.GpuBegin();
		self.GpuShader(shdTiteGpuMatrix_scale);
		self.GpuFloatN("texelA", _lhs.texel);
		self.GpuFloat1("uniScale", _factor);
		self.GpuSample("texA", _lhs);
		self.GpuTarget(self);
		self.GpuRender();
		self.GpuEnd();
		return self;
	};
	
	
	static Randomize = function(_min=0, _max=1, _seed=undefined)
	{
		_seed ??= get_timer() / 1_000_000;
		
		// Do the computation.
		self.GpuBegin();
		self.GpuShader(shdTiteGpuMatrix_scale);
		self.GpuFloatN("texelA", _lhs.texel);
		self.GpuFloat1("uniScale", _factor);
		self.GpuSample("texA", _lhs);
		self.GpuTarget(self);
		self.GpuRender();
		self.GpuEnd();
		return self;
	};
	
	


#endregion
// 
//==========================================================
//
#region GPU & SHADER OPERATING METHODS.


	static __gm_BaseTexture = undefined; // Special case for texA.
	static __previousShader = -1; // To return previous shader.


	static GpuBegin = function() 
	{
		gpu_push_state();
		gpu_set_blendmode_ext(bm_one, bm_zero);
		gpu_set_tex_filter(false);
		gpu_set_tex_repeat(false);
		gpu_set_alphatestenable(false);
		gpu_set_blendenable(false);
		gpu_set_colorwriteenable(true, true, true, true);
		return self;
	};
	
	
	static GpuEnd = function()
	{
		gpu_pop_state();
		if (TiteGpuMatrix.__previousShader != -1)
		{
			shader_set(TiteGpuMatrix.__previousShader);
		} else {
			shader_reset();
		}
		return self;
	};
	
	
	static GpuShader = function(_shader) 
	{
		TiteGpuMatrix.__previousShader = shader_current();
		shader_set(_shader);
		return self;
	};
	
	
	static GpuAdditive = function(_additive) 
	{
		if (_additive) 
		{
			gpu_set_blendenable(true);
			gpu_set_blendmode_ext(bm_one, bm_one);
		} else {
			gpu_set_blendenable(false);
			gpu_set_blendmode_ext(bm_one, bm_zero);
		}
		return self;
	};
	
	
	static GpuRepetive = function(_repetive)
	{
		gpu_set_tex_repeat(_repetive);
		return self;
	};
	
	
	static GpuInterpolate = function(_interpolate) 
	{
		gpu_set_tex_filter(_interpolate);
		return self;
	};
	
	
	static GpuFloatN = function(_name, _array)
	{
		var _shader = shader_current();
		var _uniform = shader_get_uniform(_shader, _name);
		shader_set_uniform_f_array(_uniform, _array);
		return self;
	};
	
	
	static GpuFloat1 = function(_name, _x)
	{
		var _shader = shader_current();
		var _uniform = shader_get_uniform(_shader, _name);
		shader_set_uniform_f(_uniform, _x);
		return self;
	};
	
	
	static GpuFloat2 = function(_name, _x, _y)
	{
		var _shader = shader_current();
		var _uniform = shader_get_uniform(_shader, _name);
		shader_set_uniform_f(_uniform, _x, _y);
		return self;
	};
	
	
	static GpuFloat3 = function(_name, _x, _y, _z)
	{
		var _shader = shader_current();
		var _uniform = shader_get_uniform(_shader, _name);
		shader_set_uniform_f(_uniform, _x, _y, _z);
		return self;
	};
	
	
	static GpuFloat4 = function(_name, _x, _y, _z, _w)
	{
		var _shader = shader_current();
		var _uniform = shader_get_uniform(_shader, _name);
		shader_set_uniform_f(_uniform, _x, _y, _z, _w);
		return self;
	};
	
	
	static GpuSample = function(_name, _src)
	{
		// Special case for texA, as it is gm_BaseTexture.
		// This way you can define this sampler like others.
		if (_name == "texA")
		{
			TiteGpuMatrix.__gm_BaseTexture = _src;
			return self;
		}
		
		// Define other, like texB, as sampler.
		var _shader = shader_current();
		var _sampler = shader_get_sampler_index(_shader, _name);
		texture_set_stage(_sampler, _src.Texture());
		return self;
	};
	
	
	static GpuTarget = function(_src)
	{
		surface_set_target(_src.Surface());
		return self;
	};
	
	
	static GpuRender = function()
	{
		var _target = surface_get_target();
		var _w = surface_get_width(_target);
		var _h = surface_get_height(_target);
		
		// Check whether texA has been defined.
		if (TiteGpuMatrix.__gm_BaseTexture != undefined)
		{
			var _texA = TiteGpuMatrix.__gm_BaseTexture.Surface();
			draw_surface_stretched(_texA, 0, 0, _w, _h);
		} else {
			// Add bit padding, as primitives might draw differently on different machines.
			draw_rectangle(-1, -1, _w+1, _h+1, false);
		}
		return self;
	};
	
	
	static GpuInplace = function(_dst, _func, _args)
	{
		// Render source and destination can't be same.
		// Therefore temporary target is created, and then results are copied over.
		// Should be called in context of clone, to accommodate use of "self".
		// feather ignore GM2023
		var _clone = _dst.Clone();
		method_call(method(_clone, _func), _args);
		surface_copy(_dst.Surface(), 0, 0, _clone.Surface());
		_clone.Free();
		return _dst;
	};
	

	
#endregion
// 
//==========================================================
}















