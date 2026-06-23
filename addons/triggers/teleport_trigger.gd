@tool
@icon("res://addons/triggers/icons/trigger-icon.svg")
class_name TeleportTrigger
extends Trigger

@export var target: Node2D
@export var target_position: Marker2D

func valid_config() -> bool:
	var result: bool = super.valid_config()

	if not target:
		Log.error(self , valid_config, "Missing target")
		result = false

	if not target_position:
		Log.error(self , valid_config, "Missing target position")
		result = false

	return result


func trigger() -> void:
	if not can_trigger():
		return

	if target.has_method("teleport"):
		target.teleport(target_position.global_position)
	else:
		target.global_position = target_position.global_position

	super.trigger()
