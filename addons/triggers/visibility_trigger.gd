@tool
@icon("res://addons/triggers/icons/trigger-icon-on-off.svg")
class_name VisibilityTrigger
extends Trigger

enum Action { SHOW, HIDE }

@export var target: CanvasItem
@export var action: Action = Action.SHOW


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
		Action.SHOW:
			target.visible = true
		Action.HIDE:
			target.visible = false

	super.trigger()
