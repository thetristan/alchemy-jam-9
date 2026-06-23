@tool
@icon("res://addons/triggers/icons/trigger-icon-audio.svg")
class_name AudioTrigger
extends Trigger

enum Action { PLAY, STOP }

@export var target: AudioStreamPlayer
@export var action: Action = Action.PLAY


func valid_config() -> bool:
	var result: bool = super.valid_config()

	if not target:
		Log.error(self , valid_config, "Missing target")
		result = false

	return result


func trigger() -> void:
	if not can_trigger():
		return

	match action:
		Action.PLAY:
			target.play()
		Action.STOP:
			target.stop()

	super.trigger()
