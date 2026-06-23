@tool
@icon("res://addons/triggers/icons/trigger-icon.svg")
class_name SpawnTrigger
extends Trigger

@export var target_spawns: Array[Node2D]

func valid_config() -> bool:
	var result: bool = super.valid_config()

	if not target_spawns:
		Log.error(self , valid_config, "Missing target spawns")
		result = false

	return result


func trigger() -> void:
	if not can_trigger():
		return

	for target in target_spawns:
		if target.has_method("spawn"):
			target.call("spawn")

	super.trigger()
