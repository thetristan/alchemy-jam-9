@tool
@icon("res://addons/triggers/icons/trigger-icon-seq.svg")
class_name SequenceTrigger
extends Trigger

var _last_triggered_idx: int

# @export var repeat: bool
@export var reverse_on_repeat: bool
@export var reversed: bool
@export var starting_trigger_idx: int = 0


func _ready() -> void:
	super._ready()
	valid_config()
	var start: int = clampi(starting_trigger_idx, 0, next_triggers.size() - 1)
	if reversed:
		start = next_triggers.size() - (start + 1)
	_last_triggered_idx = start - _offset()


func valid_config() -> bool:
	if reverse_on_repeat and one_shot:
		Log.error(self , valid_config, "reverse on repeat has no effect with one_shot enabled")
		return false
	return true


func _offset() -> int:
	return -1 if reversed else 1


func trigger() -> void:
	if not can_trigger():
		return

	var next_idx: int = _last_triggered_idx + _offset()

	if next_idx < 0 or next_idx >= next_triggers.size():
		if one_shot:
			trigger_used = true
			return
		if reverse_on_repeat:
			reversed = not reversed
			next_idx = _last_triggered_idx + _offset()
		else:
			next_idx = 0 if not reversed else next_triggers.size() - 1

	_last_triggered_idx = next_idx
	if deferred:
		_do_trigger.call_deferred()
	else:
		_do_trigger()


func _do_trigger() -> void:
	Log.info(self , trigger, "triggered %d" % _last_triggered_idx)
	triggered.emit()
	next_triggers[_last_triggered_idx].trigger()
