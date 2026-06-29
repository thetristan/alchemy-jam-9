@tool
@icon("res://addons/triggers/icons/trigger-icon.svg")
class_name ParticleTrigger
extends Trigger

@export var target: GPUParticles2D
@export var min_count: int = 1
@export var max_count: int = 1
@export var emitter: bool


func valid_config() -> bool:
	var result: bool = super.valid_config()

	if not target:
		Log.error(self , valid_config, "Missing target")
		result = false

	return result


func trigger() -> void:
	if not can_trigger():
		return

	target.amount = randi_range(min_count, max_count)
	if emitter:
		target.emitting = true

	super.trigger()
