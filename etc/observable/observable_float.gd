class_name ObservableFloat
extends RefCounted


signal changed(curr_value: float, prev_value: float)
signal base_changed(curr_value: float, prev_value: float)


var _base: float
var _computed: float
var _modifiers: Array[Modifier] = []


func _init(initial: float = 0.0) -> void:
	_base = initial
	_computed = initial


func set_value(value: float) -> void:
	if value == _base:
		return
	var prev_base: float = _base
	_base = value
	base_changed.emit(_base, prev_base)
	_recompute()


func update(mutator: Callable) -> float:
	set_value(mutator.call(_base))
	return _computed


func get_value() -> float:
	return _computed


func get_base_value() -> float:
	return _base


func add_modifier(modifier: Modifier) -> void:
	_modifiers.append(modifier)
	_modifiers.sort_custom(func(a: Modifier, b: Modifier) -> bool: return a.priority < b.priority)
	modifier.cancelled.connect(_modifiers.erase.bind(modifier), CONNECT_ONE_SHOT)
	modifier.cancelled.connect(_recompute, CONNECT_ONE_SHOT)
	modifier.updated.connect(_recompute)
	_recompute()


func clear_modifiers() -> void:
	if _modifiers.is_empty():
		return
	_modifiers.clear()
	_recompute()


func _recompute() -> void:
	var prev: float = _computed
	var result: float = _base
	for modifier: Modifier in _modifiers:
		result = modifier.apply(result)
	if result == prev:
		return
	_computed = result
	changed.emit(_computed, prev)


class Modifier extends RefCounted:
	signal updated
	signal cancelled

	var name: String
	var priority: int

	func apply(value: float) -> float:
		return value

	func update() -> void:
		updated.emit()

	func cancel() -> void:
		cancelled.emit()


class Offset extends Modifier:
	var amount: float

	func _init(amount_: float) -> void:
		amount = amount_

	func apply(value: float) -> float:
		return value + amount


class Scale extends Modifier:
	var factor: float

	func _init(factor_: float) -> void:
		factor = factor_

	func apply(value: float) -> float:
		return value * factor


class Clamp extends Modifier:
	var min_value: float
	var max_value: float

	func _init(min_value_: float, max_value_: float) -> void:
		min_value = min_value_
		max_value = max_value_
		priority = 1000

	func apply(value: float) -> float:
		return clampf(value, min_value, max_value)
