@tool
@icon("res://addons/triggers/icons/trigger-icon-trigger.svg")
class_name TriggerTrigger
extends Trigger

enum Action {ENABLE_TRIGGER, DISABLE_TRIGGER}
@export var action: Action = Action.DISABLE_TRIGGER

@export var triggers: Array[Trigger]
@export var cancel_delay_on_disable: bool


func _ready() -> void:
	# Wire up children
	super._ready()

	# Report any errors
	valid_config()


func valid_config() -> bool:
	var valid: bool = true

	if triggers.is_empty():
		Log.error(self , valid_config, "no triggers assigned")
		valid = false

	if triggers.any(func(v): return v == null):
		Log.error(self , valid_config, "null trigger found")
		valid = false

	return valid


func trigger() -> void:
	if not can_trigger():
		return

	match action:
		Action.ENABLE_TRIGGER:
			for t in triggers:
				Log.info(self , trigger, "enabling %s" % t.get_path())
				t.enabled = true

		Action.DISABLE_TRIGGER:
			for t in triggers:
				Log.info(self , trigger, "disabling %s" % t.get_path())
				t.enabled = false

				if cancel_delay_on_disable and t is DelayTrigger:
					t.cancel()

	super.trigger()
