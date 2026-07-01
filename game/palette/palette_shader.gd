class_name PaletteShader
extends ColorRect

const GROUP: String = "palette_shader"
const BRIGHTNESS_PARAM: String = "brightness"
const USE_FIXED_PALETTE_PARAM: String = "use_fixed_palette"
const FIXED_SOURCE_PALETTE_PARAM: String = "fixed_source_palette"

var flashed: bool = false
var flash_tween: Tween
var fade_tween: Tween

const FLICKER_FPS: float = 12.0
const FLICKER_INTERVAL: float = 1.0 / FLICKER_FPS

var flicker_time: float = 0.0
var flicker_accumulator: float = 0.0
var flicker_brightness: float = 0.0

@export var enable_flicker: bool = false:
	set(new_val):
		# Remove the current flicker contribution when turning flicker off.
		# Write straight to the shader so we don't re-enter the brightness setter
		# (which would recurse back into disabling the flicker).
		if enable_flicker and not new_val:
			shader_material.set_shader_parameter(BRIGHTNESS_PARAM,
				shader_material.get_shader_parameter(BRIGHTNESS_PARAM) - flicker_brightness)
			flicker_brightness = 0.0
		enable_flicker = new_val
@export var flicker_noise: Noise
@export var flicker_scale: float = 4.0
@export var min_flicker: float = -0.25
@export var max_flicker: float = 0.25
@export var global: bool = true


var shader_material: ShaderMaterial:
	get: return material as ShaderMaterial
	set(new_val): pass


@export var brightness: float:
	get: return shader_material.get_shader_parameter(BRIGHTNESS_PARAM)
	set(new_val):
		# A direct brightness change (from anything other than the flicker) cancels
		# flickering first, so it can't keep overwriting the value just set.
		if enable_flicker:
			enable_flicker = false
		shader_material.set_shader_parameter(BRIGHTNESS_PARAM, new_val)

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


func _process(delta: float) -> void:
	if not enable_flicker or flicker_noise == null:
		return

	flicker_accumulator += delta
	if flicker_accumulator < FLICKER_INTERVAL:
		return
	flicker_accumulator -= FLICKER_INTERVAL

	flicker_time += FLICKER_INTERVAL * flicker_scale
	var weight: float = flicker_noise.get_noise_1d(flicker_time) * 0.5 + 0.5

	# Track the flicker offset separately and add it on top of the current base
	# brightness. Write straight to the shader (not through the brightness setter,
	# which would treat it as an external change and disable the flicker).
	var base: float = shader_material.get_shader_parameter(BRIGHTNESS_PARAM) - flicker_brightness
	flicker_brightness = lerpf(min_flicker, max_flicker, weight)
	shader_material.set_shader_parameter(BRIGHTNESS_PARAM, base + flicker_brightness)


func _ready() -> void:
	if global:
		add_to_group(GROUP)
