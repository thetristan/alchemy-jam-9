@tool
@icon("res://addons/triggers/icons/trigger-icon-delay.svg")
class_name DelayTrigger
extends Trigger

@export var start_on_ready: bool
@export var delay: float = 0.5
@export var min_delay: float = 0.0
@export var max_delay: float = 0.0
@export var allow_parallel: bool
@export var emit_delay_progress: bool

var delay_started: bool
var _active_delays: Dictionary[int, float]
var _delay_durations: Dictionary[int, float]
var _next_delay_id: int


func _ready() -> void:
	# Wire up children
	super._ready()

	process_mode = Node.PROCESS_MODE_PAUSABLE

	# Report any errors
	valid_config()

	if not Engine.is_editor_hint() and start_on_ready:
		trigger()


func valid_config() -> bool:
	if allow_parallel and one_shot:
		Log.error(self , valid_config, "cannot enable allow_parallel and one_shot at the same time")
		return false

	return true


func _process(delta: float) -> void:
	var to_erase: Array[int]

	for id in _active_delays:
		_active_delays[id] = max(0, _active_delays[id] - delta)
		if is_zero_approx(_active_delays[id]):
			Log.info(self , trigger, "delay finished")
			to_erase.append(id)
			super.trigger()

	for id in to_erase:
		_active_delays.erase(id)
		_delay_durations.erase(id)

	if _active_delays.is_empty():
		if delay_started and emit_delay_progress:
			var empty_result: Dictionary[int, float]
			SignalBus.delay_progressed.emit(self , empty_result)
		delay_started = false

	elif emit_delay_progress:
		var progress: Dictionary[int, float] = _active_delays.duplicate()
		for p in progress:
			progress[p] = progress[p] / _delay_durations[p]
		SignalBus.delay_progressed.emit(self , progress)


func trigger() -> void:
	if not can_trigger():
		return

	delay_started = true

	var active_delay: float = delay
	if not is_zero_approx(min_delay) or not is_zero_approx(max_delay):
		active_delay = randf_range(min_delay, max_delay)

	Log.info(self , trigger, "starting trigger delay of %0.2fs" % active_delay)
	_active_delays[_next_delay_id] = active_delay
	_delay_durations[_next_delay_id] = active_delay
	_next_delay_id += 1


func cancel() -> void:
	Log.debug(self , trigger, "active delays cancelled")
	_active_delays.clear()
	_delay_durations.clear()
