extends Node

const MUSIC_BUS: StringName = &"Music"
const SFX_BUS: StringName = &"SFX"

const MUSIC_VOLUME_KEY: StringName = &"music_volume"
const SFX_VOLUME_KEY: StringName = &"sfx_volume"

const OPTIONS_PATH: String = "user://options.dat"

@export var debug_mode: bool = false

var music_volume: ObservableFloat = ObservableFloat.new()
var sfx_volume: ObservableFloat = ObservableFloat.new()
var _store: ObservableStore


func save_options() -> void:
	_store.save()


func _ready() -> void:
	music_volume.changed.connect(_on_music_changed)
	sfx_volume.changed.connect(_on_sfx_changed)
	# Seed defaults from the bus layout so a missing save file persists the layout's volumes.
	music_volume.set_value(_get_bus_volume(MUSIC_BUS))
	sfx_volume.set_value(_get_bus_volume(SFX_BUS))
	# Loads persisted values (applied to the buses via `changed`); does not auto-save on edits.
	_store = ObservableStore.new(OPTIONS_PATH, {
		MUSIC_VOLUME_KEY: music_volume,
		SFX_VOLUME_KEY: sfx_volume,
	}, false)


func _on_music_changed(curr_value: float, _prev_value: float) -> void:
	_update_bus_volume(MUSIC_BUS, curr_value)


func _on_sfx_changed(curr_value: float, _prev_value: float) -> void:
	_update_bus_volume(SFX_BUS, curr_value)


func _get_bus_volume(bus_name: StringName) -> float:
	var idx: int = AudioServer.get_bus_index(bus_name)
	return AudioServer.get_bus_volume_linear(idx)


func _update_bus_volume(bus_name: StringName, volume: float) -> void:
	var idx: int = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_linear(idx, volume)
