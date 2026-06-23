class_name ObservableStore
extends RefCounted
## Persists a named set of observable values to disk.

var _path: String
var _observables: Dictionary
var _loading: bool = false


func _init(path: String, observables: Dictionary, auto_save: bool = true) -> void:
	_path = path
	_observables = observables
	if auto_save:
		for key: StringName in _observables:
			var observable: Object = _observables[key]
			observable.base_changed.connect(_on_base_changed)
	_load()


## Manually flush the current base values to disk.
func save() -> void:
	_save()


func _on_base_changed(_curr: Variant, _prev: Variant) -> void:
	if not _loading:
		_save()


func _load() -> void:
	var data: Dictionary = _read_data()
	_loading = true
	var complete: bool = true
	for key: StringName in _observables:
		if data.has(key):
			var observable: Object = _observables[key]
			observable.set_value(data[key])
		else:
			complete = false
	_loading = false
	if not complete:
		_save()


func _read_data() -> Dictionary:
	var file: FileAccess = FileAccess.open(_path, FileAccess.READ)
	if not file:
		return {}
	var data: Variant = file.get_var()
	file.close()
	return data if data is Dictionary else {}


func _save() -> void:
	var file: FileAccess = FileAccess.open(_path, FileAccess.WRITE)
	if not file:
		return
	var data: Dictionary = {}
	for key: StringName in _observables:
		var observable: Object = _observables[key]
		data[key] = observable.get_base_value()
	file.store_var(data)
	file.close()
