class_name PaletteShader
extends ColorRect

const GROUP: String = "palette_shader"
const BRIGHTNESS_PARAM: String = "brightness"
const USE_FIXED_PALETTE_PARAM: String = "use_fixed_palette"
const FIXED_SOURCE_PALETTE_PARAM: String = "fixed_source_palette"

var flashed: bool = false
var flash_tween: Tween
var fade_tween: Tween


var shader_material: ShaderMaterial:
	get: return material as ShaderMaterial
	set(new_val): pass


@export var brightness: float:
	get: return shader_material.get_shader_parameter(BRIGHTNESS_PARAM)
	set(new_val): shader_material.set_shader_parameter(BRIGHTNESS_PARAM, new_val)

@export var use_fixed_palette: bool:
	get: return shader_material.get_shader_parameter(USE_FIXED_PALETTE_PARAM)
	set(new_val): shader_material.set_shader_parameter(USE_FIXED_PALETTE_PARAM, new_val)

@export var fixed_source_palette: Texture2D:
	get: return shader_material.get_shader_parameter(FIXED_SOURCE_PALETTE_PARAM)
	set(new_val): shader_material.set_shader_parameter(FIXED_SOURCE_PALETTE_PARAM, new_val)


static func get_instance() -> PaletteShader:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if not tree:
		return null
	return tree.get_first_node_in_group(GROUP) as PaletteShader


func fade_in(duration: float = 0.08333 * 2, target_brightness: float = 0) -> void:
	if fade_tween:
		return

	fade_tween = create_tween()
	fade_tween.tween_property(self, "brightness", target_brightness, duration)
	await fade_tween.finished
	fade_tween.kill()
	fade_tween = null


func fade_out(duration: float = 0.08333 * 2) -> void:
	if fade_tween:
		return

	fade_tween = create_tween()
	fade_tween.tween_property(self, "brightness", -1, duration)
	await fade_tween.finished
	fade_tween.kill()
	fade_tween = null


func flash(duration: float = 0.08333 * 2, override_brightness: float = 0.5, fade: bool = true) -> void:
	if flash_tween:
		return

	var original_brightness: float = brightness
	brightness = override_brightness

	if fade:
		flash_tween = create_tween()
		flash_tween.tween_property(self, "brightness", -0.25, duration)
		await flash_tween.finished
		flash_tween.kill()
		flash_tween = null
	else:
		await get_tree().create_timer(duration, false).timeout
		brightness = original_brightness


func _ready() -> void:
	add_to_group(GROUP)
