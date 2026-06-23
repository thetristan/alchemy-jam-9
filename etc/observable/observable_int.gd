class_name ObservableInt
extends RefCounted


signal changed(curr_value: int, prev_value: int)
signal base_changed(curr_value: int, prev_value: int)


var _base: int
var _computed: int
var _modifiers: Array[Modifier] = []


func _init(initial: int = 0) -> void:
	_base = initial
	_computed = initial


func set_value(value: int) -> void:
	if value == _base:
		return
	var prev_base: int = _base
	_base = value
	base_changed.emit(_base, prev_base)
	_recompute()


func update(mutator: Callable) -> int:
	set_value(mutator.call(_base))
	return _computed


func get_value() -> int:
	return _computed


func get_base_value() -> int:
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
	var prev: int = _computed
	var result: int = _base
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

	func apply(value: int) -> int:
		return value

	func update() -> void:
		updated.emit()

	func cancel() -> void:
		cancelled.emit()


class Offset extends Modifier:
	var amount: int

	func _init(amount_: int) -> void:
		amount = amount_

	func apply(value: int) -> int:
		return value + amount


class Scale extends Modifier:
	var factor: int

	func _init(factor_: int) -> void:
		factor = factor_

	func apply(value: int) -> int:
		return value * factor


class Clamp extends Modifier:
	var min_value: int
	var max_value: int

	func _init(min_value_: int, max_value_: int) -> void:
		min_value = min_value_
		max_value = max_value_
		priority = 1000

	func apply(value: int) -> int:
		return clampi(value, min_value, max_value)
