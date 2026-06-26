class_name BleazyTween
extends RefCounted

signal finished
signal looped(loop_count: int)

enum LoopMode { NONE, LOOP, BOUNCE }

var _easing_type: Easing.Type
var _duration: float
var _begin: float
var _change: float
var _elapsed: float
var _loop_mode: LoopMode
var _active: bool
var _forward: bool
var _loop_count: int


func _init(from: float, to: float, dur: float, easing: Easing.Type = Easing.Type.LINEAR) -> void:
	_begin = from
	_change = to - from
	_duration = dur
	_easing_type = easing
	_elapsed = 0.0
	_active = true
	_forward = true
	_loop_count = 0


func set_loop_mode(mode: LoopMode) -> BleazyTween:
	_loop_mode = mode
	return self


func update(delta: float) -> float:
	if not _active:
		return _current_value()

	_elapsed += delta

	if _elapsed >= _duration:
		_on_segment_finished()

	return _current_value()


func is_active() -> bool:
	return _active


func reset(from: float, to: float, dur: float) -> void:
	_begin = from
	_change = to - from
	_duration = dur
	_elapsed = 0.0
	_forward = true
	_active = true


func _current_value() -> float:
	var t: float = minf(_elapsed, _duration)
	if _forward:
		return Easing.ease_func(_easing_type, t, _begin, _change, _duration)
	else:
		return Easing.ease_func(_easing_type, t, _begin + _change, -_change, _duration)


func _on_segment_finished() -> void:
	match _loop_mode:
		LoopMode.NONE:
			_elapsed = _duration
			_active = false
			finished.emit()

		LoopMode.LOOP:
			_elapsed -= _duration
			_loop_count += 1
			looped.emit(_loop_count)

		LoopMode.BOUNCE:
			_elapsed -= _duration
			_forward = not _forward
			if _forward:
				_loop_count += 1
				looped.emit(_loop_count)
