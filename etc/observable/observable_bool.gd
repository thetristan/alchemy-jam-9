class_name ObservableBool
extends RefCounted


signal changed(curr_value: bool, prev_value: bool)
signal base_changed(curr_value: bool, prev_value: bool)


var _base: bool
var _computed: bool
var _modifiers: Array[Modifier] = []


func _init(initial: bool = false) -> void:
	_base = initial
	_computed = initial


func set_value(value: bool) -> void:
	if value == _base:
		return
	var prev_base: bool = _base
	_base = value
	base_changed.emit(_base, prev_base)
	_recompute()


func update(mutator: Callable) -> bool:
	set_value(mutator.call(_base))
	return _computed


func get_value() -> bool:
	return _computed


func get_base_value() -> bool:
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
	var prev: bool = _computed
	var result: bool = _base
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

	func apply(value: bool) -> bool:
		return value

	func update() -> void:
		updated.emit()

	func cancel() -> void:
		cancelled.emit()


class And extends Modifier:
	var operand: bool

	func _init(operand_: bool) -> void:
		operand = operand_

	func apply(value: bool) -> bool:
		return value and operand


class Or extends Modifier:
	var operand: bool

	func _init(operand_: bool) -> void:
		operand = operand_

	func apply(value: bool) -> bool:
		return value or operand


class Not extends Modifier:
	func apply(value: bool) -> bool:
		return not value
