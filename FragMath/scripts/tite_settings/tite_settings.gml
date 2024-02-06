
#macro tite_forceinline gml_pragma("forceinline")


// Helper global variables.
global.tite = {}; 
global.tite.previousShader = [-1];		// Stores so it can be return after calculations are done.
global.tite.cumulative = false;			// Store next calculation as cumulative result.
global.tite.vertexFormat = undefined;
global.tite.vertexBuffer = undefined;


// Create vertex format and buffer to render whole render area.
// Calculations are assumed to use simplified vertex shader, 
// so it won't add any projections. Vbuff assumes pr_trianglestrip.
vertex_format_begin();
vertex_format_add_position();
global.tite.vertexFormat = vertex_format_end();
global.tite.vertexBuffer = vertex_create_buffer();
var _vbuff = global.tite.vertexBuffer;
vertex_begin(_vbuff, global.tite.vertexFormat);
vertex_position(_vbuff, -1.0, -1.0);
vertex_position(_vbuff, +1.0, -1.0);
vertex_position(_vbuff, -1.0, +1.0);
vertex_position(_vbuff, +1.0, +1.0);
// Funny small optimization to cover whole render area with single triangle.
//vertex_position(_vbuff, -1.0, -1.0); // Fragments are usually done in 2x2, so triangle edges have bit overhead.
//vertex_position(_vbuff, +3.0, -1.0); // So this avoid having edge, and uses only single triangle.
//vertex_position(_vbuff, -1.0, +3.0); // 
vertex_end(_vbuff);
vertex_freeze(_vbuff);