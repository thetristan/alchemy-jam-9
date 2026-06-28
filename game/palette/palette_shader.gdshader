shader_type canvas_item;

// Sourced from https://godotshaders.com/shader/game-boy-palette-overlay/

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float brightness : hint_range(-1, 1) = 0;
uniform sampler2D source_palette;
uniform sampler2D target_palette;

uniform bool use_fixed_palette = false;
uniform bool screen_shader = true;
uniform sampler2D fixed_source_palette;

void fragment() {
	
	vec4 src_color;
	if (screen_shader) {
		src_color = texture(screen_texture, SCREEN_UV);
	} else {
		src_color = texture(TEXTURE, UV);
	}
	
	ivec2 pal_size = textureSize(source_palette, 0);

	float color_diff = 1.0;
	int nearest_swatch = 0;

	for (int swatch=0; swatch < pal_size.x; swatch++) {
		vec4 sampled_color = texelFetch(source_palette, ivec2(swatch,0), 0);
		float new_color_diff = distance(sampled_color, src_color);

		if (new_color_diff < color_diff) {
			color_diff = new_color_diff;
			nearest_swatch = swatch;
		}
	}

	bool matched_fixed = false;
	int nearest_fixed_swatch = 0;

	if (use_fixed_palette) {
		ivec2 fixed_pal_size = textureSize(fixed_source_palette, 0);
		float fixed_color_diff = 1.0;

		for (int swatch=0; swatch < fixed_pal_size.x; swatch++) {
			vec4 sampled_color = texelFetch(fixed_source_palette, ivec2(swatch,0), 0);
			float new_color_diff = distance(sampled_color, src_color);

			if (new_color_diff < fixed_color_diff) {
				fixed_color_diff = new_color_diff;
				nearest_fixed_swatch = swatch;
			}
		}

		matched_fixed = fixed_color_diff < color_diff;
	}

	int target_swatch;
	if (matched_fixed) {
		target_swatch = nearest_fixed_swatch;
	} else {
		int swatch_offset = int(brightness * float(pal_size.x));
		target_swatch = clamp(nearest_swatch + swatch_offset, 0, pal_size.x - 1);
	}

	vec4 dst_color = texelFetch(target_palette, ivec2(target_swatch, 0), 0);
	dst_color.a = src_color.a;
	COLOR = dst_color;
}
