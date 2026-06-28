@tool
@icon("res://components/triggers/icons/trigger-icon-moving.svg")
class_name PathTrigger
extends Trigger

@export var target_path_follower: TriggeredPathFollower
@export var target_ratio: float
@export var duration: float = 0.5


func valid_config() -> bool:
	var result: bool = super.valid_config()

	if not target_path_follower:
		Log.error(self , valid_config, "Missing target path")
		result = false

	return result


func trigger() -> void:
	if not can_trigger():
		return

	target_path_follower.move_to(target_ratio, duration)

	super.trigger()
