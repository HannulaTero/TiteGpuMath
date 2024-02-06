/// @desc MAKE TEXT.

depth = -2000;
text = "";


// Give general lines for controls.
text += string_join("\n", 
	"Hold R to Randomize.",
	"Hold Enter to Update continuously.",
	"Press Space to Update once.",
	"Press Up/Down to resize matrices.",
	"Hold Left to add randomness to position.",
	"Hold Right to add randomness to speed."
);


// Give warning about hacky rendering tactic in windows.
if (os_browser == browser_not_a_browser)
{
	text += string_join("\n", 
		"\n\nWarning!", 
		" -> On windows hacky particle rendering!",
		" -> This can be particularly slow with big matrixes."
	);
}


// Give warning as particle behaviour is best with rgba32float.
if (!surface_format_is_supported(surface_rgba32float))
{
	text += string_join("\n", 
		"\n\nWarning!", 
		" -> rgba32float not supported!", 
		surface_format_is_supported(surface_rgba16float)
			? " -> Using rgba16float! Best with rgba32float."
			: " -> Using rgba8unorm!!! Particles won't work!"
	);
}




