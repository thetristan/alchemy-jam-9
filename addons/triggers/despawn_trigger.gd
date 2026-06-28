@tool
@icon("res://addons/triggers/icons/trigger-icon.svg")
class_name DespawnTrigger
extends Trigger
## Frees the target node, then continues the trigger chain.

@export var target: Node


func valid_config() -> bool:
	var result: bool = super.valid_config()

	if not target:
		Log.error(self , valid_config, "Missing target")
		result = false

	return result


func trigger() -> void:
	if not can_trigger():
		return

	target.queue_free()
	super.trigger()
