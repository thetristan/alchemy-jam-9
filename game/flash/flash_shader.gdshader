shader_type canvas_item;

uniform bool active = false;
uniform vec3 flash_color : source_color = vec3(1.0, 1.0, 1.0);

void fragment() {
	vec4 previous_color = texture(TEXTURE, UV);
	if (active) {
		COLOR = vec4(flash_color, previous_color.a);
	} else {
		COLOR = previous_color;
	}
}