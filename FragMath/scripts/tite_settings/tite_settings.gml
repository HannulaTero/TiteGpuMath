
#macro	TITE				global.g_tite
#macro	tite_forceinline	gml_pragma("forceinline")


// Helper global variables.
TITE = {}; 
TITE.previousShader = [-1];		// Stores so it can be return after calculations are done.
TITE.cumulative = false;		// Store next calculation as cumulative result.
TITE.vertexFormat = undefined;
TITE.vertexBuffer = undefined;


// Create vertex format and vertex buffer.
// These are meant to cover whole render area.
// Calculations are assumed to use simplified vertex shader, 
// so it won't add any projections. Vbuff assumes pr_trianglestrip.
vertex_format_begin();
vertex_format_add_position();
TITE.vertexFormat = vertex_format_end();
TITE.vertexBuffer = vertex_create_buffer();
var _vbuff = TITE.vertexBuffer;
vertex_begin(_vbuff, TITE.vertexFormat);
vertex_position(_vbuff, -1.0, -1.0);
vertex_position(_vbuff, +1.0, -1.0);
vertex_position(_vbuff, -1.0, +1.0);
vertex_position(_vbuff, +1.0, +1.0);
vertex_end(_vbuff);
vertex_freeze(_vbuff);
/* 
// Funny small optimization to cover whole render area with single triangle.
// Fragments are usually done in 2x2, so triangle edges have bit overhead.
// So this avoid having edge, and uses only single triangle.
vertex_position(_vbuff, -1.0, -1.0);
vertex_position(_vbuff, +3.0, -1.0);
vertex_position(_vbuff, -1.0, +3.0);
*/