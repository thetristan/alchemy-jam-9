class_name ObservableVariant
extends RefCounted


signal changed(curr_value: Variant, prev_value: Variant)
signal base_changed(curr_value: Variant, prev_value: Variant)


var _base: Variant
var _computed: Variant
var _modifiers: Array[Modifier] = []


func _init(initial: Variant = null) -> void:
	_base = initial
	_computed = initial


func set_value(value: Variant) -> void:
	if value == _base:
		return
	var prev_base: Variant = _base
	_base = value
	base_changed.emit(_base, prev_base)
	_recompute()


func update(mutator: Callable) -> Variant:
	set_value(mutator.call(_base))
	return _computed


func get_value() -> Variant:
	return _computed


func get_base_value() -> Variant:
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
	var prev: Variant = _computed
	var result: Variant = _base
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

	func apply(value: Variant) -> Variant:
		return value

	func update() -> void:
		updated.emit()

	func cancel() -> void:
		cancelled.emit()


class Offset extends Modifier:
	var amount: Variant

	func _init(amount_: Variant) -> void:
		amount = amount_

	func apply(value: Variant) -> Variant:
		return value + amount


class Scale extends Modifier:
	var factor: Variant

	func _init(factor_: Variant) -> void:
		factor = factor_

	func apply(value: Variant) -> Variant:
		return value * factor


class Clamp extends Modifier:
	var min_value: Variant
	var max_value: Variant

	func _init(min_value_: Variant, max_value_: Variant) -> void:
		min_value = min_value_
		max_value = max_value_
		priority = 1000

	func apply(value: Variant) -> Variant:
		return clamp(value, min_value, max_value)
