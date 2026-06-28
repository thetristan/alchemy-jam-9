shader_type canvas_item;

uniform int seed_a;
uniform int seed_b;
uniform float coverage : hint_range(0.0, 1.0) = 1.0;
uniform sampler2D noise : filter_linear, repeat_enable;
uniform float noise_scale = 0.05;

// Radial gradient (white centre -> black edges) weighting how likely a column
// clump is removed; centre of the image is most likely to be missing.
uniform sampler2D column_gradient : hint_default_black, filter_linear;
uniform float column_scale = 0.03;
uniform float column_strength : hint_range(0.0, 1.0) = 1.0;
uniform float eaten_row_chance : hint_range(0.0, 1.0) = 0.5;

float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void fragment() {
	int row = int(floor(UV.y / TEXTURE_PIXEL_SIZE.y));
	float fr = float(row);

	// Walk a diagonal across the 2-D noise rather than a single column; the U
	// step is an irrational-ish fraction of the V step so the sampled track
	// effectively never repeats. Seeds offset both axes for distinct patterns.
	vec2 noise_uv = vec2(
		fr * noise_scale * 0.387 + float(seed_a) * 0.123,
		fr * noise_scale + float(seed_b) * 0.071
	);
	float r = texture(noise, noise_uv).r;
	float visible = coverage >= 1.0 ? 1.0 : (coverage > r ? 1.0 : 0.0);

	// Knock clumps of columns out of a random subset of rows. Low-frequency
	// noise along X groups the missing columns; the per-row V offset gives each
	// eaten row a different hole pattern; the radial gradient biases removal
	// toward the image centre.
	int col = int(floor(UV.x / TEXTURE_PIXEL_SIZE.x));
	vec2 col_uv = vec2(
		float(col) * column_scale + float(seed_a) * 0.137,
		fr * 0.13 + float(seed_b) * 0.211
	);
	float col_noise = texture(noise, col_uv).r;
	float absence = texture(column_gradient, UV).r * column_strength;
	float row_eaten = step(hash21(vec2(fr, float(seed_a) + float(seed_b) * 0.7)), eaten_row_chance);
	float present = 1.0 - row_eaten * step(col_noise, absence);

	vec4 tex = texture(TEXTURE, UV);
	COLOR = vec4(tex.rgb, tex.a * visible * present);
}
