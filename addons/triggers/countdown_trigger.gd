@tool
@icon("res://addons/triggers/icons/trigger-icon-countdown.svg")
class_name CountdownTrigger
extends Trigger

@export var count: int = 3
@onready var _count_remaining: int = count

signal countdown_changed(remaining: int)


func trigger() -> void:
	if not can_trigger():
		return

	_count_remaining -= 1
	countdown_changed.emit(_count_remaining)
	Log.info(self , trigger, "count remaining %d" % [_count_remaining])
	if not _count_remaining:
		super.trigger()
		if not one_shot:
			Log.info(self , trigger, "resetting count to %d" % [count])
			_count_remaining = count
