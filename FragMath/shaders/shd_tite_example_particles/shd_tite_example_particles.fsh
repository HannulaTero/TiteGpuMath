// Varyings.
varying vec2 vCoord;

// Uniforms.
uniform vec4 uniColor;

// Main function.
void main()
{
	gl_FragColor = uniColor * texture2D(gm_BaseTexture, vCoord);
}
