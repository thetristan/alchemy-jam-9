class_name StaticFX
extends AnimatedSprite2D


const GROUP: String = "static"

static func get_instance() -> StaticFX:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if not tree:
		return null

	return tree.get_first_node_in_group(GROUP) as StaticFX


@export var seed_a: int = 0:
	set(value):
		seed_a = value
		_update_shader_param(&"seed_a", value)

@export var seed_b: int = 0:
	set(value):
		seed_b = value
		_update_shader_param(&"seed_b", value)

@export_range(0.0, 1.0) var coverage: float = 1.0:
	set(value):
		coverage = value
		_update_shader_param(&"coverage", value)

@export var noise: Texture2D:
	set(value):
		noise = value
		_update_shader_param(&"noise", value)

@export var noise_scale: float = 0.05:
	set(value):
		noise_scale = value
		_update_shader_param(&"noise_scale", value)

@export var column_gradient: Texture2D:
	set(value):
		column_gradient = value
		_update_shader_param(&"column_gradient", value)

@export var column_scale: float = 0.03:
	set(value):
		column_scale = value
		_update_shader_param(&"column_scale", value)

@export_range(0.0, 1.0) var column_strength: float = 1.0:
	set(value):
		column_strength = value
		_update_shader_param(&"column_strength", value)

@export_range(0.0, 1.0) var eaten_row_chance: float = 0.5:
	set(value):
		eaten_row_chance = value
		_update_shader_param(&"eaten_row_chance", value)


var _initial_values: Dictionary = {}


func _ready() -> void:
	add_to_group(GROUP)
	show()
	_capture_initial_values()
	_apply_all_params()


func reset() -> void:
	for property: StringName in _initial_values:
		set(property, _initial_values[property])


func _capture_initial_values() -> void:
	_initial_values = {
		&"seed_a": seed_a,
		&"seed_b": seed_b,
		&"coverage": coverage,
		&"noise": noise,
		&"noise_scale": noise_scale,
		&"column_gradient": column_gradient,
		&"column_scale": column_scale,
		&"column_strength": column_strength,
		&"eaten_row_chance": eaten_row_chance,
	}


func _apply_all_params() -> void:
	_update_shader_param(&"seed_a", seed_a)
	_update_shader_param(&"seed_b", seed_b)
	_update_shader_param(&"coverage", coverage)
	_update_shader_param(&"noise", noise)
	_update_shader_param(&"noise_scale", noise_scale)
	_update_shader_param(&"column_gradient", column_gradient)
	_update_shader_param(&"column_scale", column_scale)
	_update_shader_param(&"column_strength", column_strength)
	_update_shader_param(&"eaten_row_chance", eaten_row_chance)


func _update_shader_param(param: StringName, value: Variant) -> void:
	var mat: ShaderMaterial = material as ShaderMaterial
	if mat:
		mat.set_shader_parameter(param, value)
