class_name ObservableString
extends RefCounted


signal changed(curr_value: String, prev_value: String)
signal base_changed(curr_value: String, prev_value: String)


var _base: String
var _computed: String
var _modifiers: Array[Modifier] = []


func _init(initial: String = "") -> void:
	_base = initial
	_computed = initial


func set_value(value: String) -> void:
	if value == _base:
		return
	var prev_base: String = _base
	_base = value
	base_changed.emit(_base, prev_base)
	_recompute()


func update(mutator: Callable) -> String:
	set_value(mutator.call(_base))
	return _computed


func get_value() -> String:
	return _computed


func get_base_value() -> String:
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
	var prev: String = _computed
	var result: String = _base
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

	func apply(value: String) -> String:
		return value

	func update() -> void:
		updated.emit()

	func cancel() -> void:
		cancelled.emit()


class Prefix extends Modifier:
	var text: String

	func _init(text_: String) -> void:
		text = text_

	func apply(value: String) -> String:
		return text + value


class Suffix extends Modifier:
	var text: String

	func _init(text_: String) -> void:
		text = text_

	func apply(value: String) -> String:
		return value + text
