@tool
@icon("res://addons/triggers/icons/trigger-icon.svg")
class_name RailTrigger
extends Trigger

enum Action {
	ENABLE,
	DISABLE,
}

@export var rail: Rail
@export var action: Action = Action.ENABLE


func valid_config() -> bool:
	if rail == null:
		Log.debug(self, valid_config, "rail is null")
		return false

	return true


func _do_trigger() -> void:
	match action:
		Action.ENABLE:
			rail.enable()
		Action.DISABLE:
			rail.disable()

	super._do_trigger()
