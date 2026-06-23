@icon("res://addons/triggers/icons/trigger-icon.svg")
@tool
class_name Trigger
extends Node

signal triggered

@export var enabled: bool = true
@export var one_shot: bool
@export var deferred: bool
@export var next_triggers: Array[Trigger]:
	set(new_val):
		next_triggers = new_val
		update_configuration_warnings()

@export var manually_connected: bool:
	set(new_val):
		manually_connected = new_val
		update_configuration_warnings()

var trigger_used: bool


func _ready() -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()

	else:
		# Disable processing for triggers
		process_mode = Node.PROCESS_MODE_DISABLED

		if next_triggers.is_empty():
			for child in get_children():
				var next_trigger: Trigger = child as Trigger
				if next_trigger and not next_trigger.manually_connected:
					Log.debug(self , _ready, "Adding child as next trigger (%s)" % next_trigger.get_path())
					next_triggers.append(next_trigger)
					

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if manually_connected:
		warnings.append("Trigger will not be connected using the scene tree and must be manually connected instead")

	if not next_triggers.is_empty():
		warnings.append("Trigger will not be connected using the scene tree and will rely on manual connections instead")

	return warnings


func can_trigger() -> bool:
	if not enabled:
		Log.debug(self , can_trigger, "trigger disabled")
		return false

	if one_shot and trigger_used:
		Log.debug(self , can_trigger, "one shot trigger already used")
		return false

	if not valid_config():
		Log.debug(self , can_trigger, "trigger has invalid config")
		return false

	return true


func valid_config() -> bool:
	return true


func trigger() -> void:
	if not can_trigger():
		return

	trigger_used = true
	if deferred:
		_do_trigger.call_deferred()
	else:
		_do_trigger()


func _do_trigger() -> void:
	Log.info(self , _do_trigger, "triggered")
	triggered.emit()
	for output in next_triggers:
		output.trigger()
