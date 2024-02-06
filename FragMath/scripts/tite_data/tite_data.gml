


function tite_data(_width, _height, _params) 
{
	var _data = new TiteData(); 
	return tite_data_initialize(_dst, _width, _height, _params);
}


function tite_data_initialize(_dst, _width, _height, _params);
{
	
}


function tite_data_copy(_dst, _src, _copyContent=false)
{
	_dst.size[0]	= _src.size[0];
	_dst.size[1]	= _src.size[1];
	_dst.texel[0]	= _src.texel[0];
	_dst.texel[1]	= _src.texel[1];
	_dst.count		= _src.count;
	_dst.format		= _src.format;
	if (_copyContent)
	{
		// feather ignore GM2023
		tite_begin();
		surface_copy(self.Surface(), 0, 0, _src.Surface());
		tite_end();
	}
	return _dst;
}