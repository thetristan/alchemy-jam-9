@tool
@icon("res://addons/triggers/icons/trigger-icon-trigger.svg")
class_name SwitchTrigger
extends Trigger

enum Action {ENABLE_SWITCH, DISABLE_SWITCH, DISPLAY_ON, DISPLAY_OFF}
@export var action: Action = Action.DISABLE_SWITCH

@export var switches: Array[Switcher]


func _ready() -> void:
	# Wire up children
	super._ready()

	# Report any errors
	valid_config()


func valid_config() -> bool:
	var valid: bool = true

	if switches.is_empty():
		Log.error(self , valid_config, "no switches assigned")
		valid = false

	if switches.any(func(v): return v == null):
		Log.error(self , valid_config, "null switch found")
		valid = false

	return valid


func trigger() -> void:
	if not can_trigger():
		return

	for s in switches:
		Log.info(self , trigger, "%s %s" % [Action.keys()[action], s.get_path()])
		match action:
			Action.ENABLE_SWITCH:
				s.set_switch_enabled(true)
			Action.DISABLE_SWITCH:
				s.set_switch_enabled(false)
			Action.DISPLAY_ON:
				s.set_display_on(true)
			Action.DISPLAY_OFF:
				s.set_display_on(false)

	super.trigger()
