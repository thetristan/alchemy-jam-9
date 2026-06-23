class_name Options
extends CanvasLayer

@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider

@onready var save_btn: Button = %Save
@onready var cancel_btn: Button = %Cancel

var _original_music_volume: float
var _original_sfx_volume: float


func _ready() -> void:
	_original_music_volume = GameOptions.music_volume.get_value()
	_original_sfx_volume = GameOptions.sfx_volume.get_value()

	music_slider.value = GameOptions.music_volume.get_value()
	sfx_slider.value = GameOptions.sfx_volume.get_value()

	music_slider.value_changed.connect(func(value: float): GameOptions.music_volume.set_value(value))
	sfx_slider.value_changed.connect(func(value: float): GameOptions.sfx_volume.set_value(value))

	save_btn.pressed.connect(on_save_options)
	cancel_btn.pressed.connect(on_cancel_options)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		on_cancel_options()


func on_save_options() -> void:
	GameOptions.save_options()
	_do_hide()


func on_cancel_options() -> void:
	GameOptions.music_volume.set_value(_original_music_volume)
	GameOptions.sfx_volume.set_value(_original_sfx_volume)
	_do_hide()


func _do_hide() -> void:
	_disable_buttons()
	SceneManager.pop_scene()


func on_focus() -> void:
	_enable_buttons()
	music_slider.grab_focus()


func _enable_buttons() -> void:
	music_slider.editable = true
	sfx_slider.editable = true

	save_btn.disabled = false
	cancel_btn.disabled = false


func _disable_buttons() -> void:
	music_slider.editable = false
	sfx_slider.editable = false

	save_btn.disabled = true
	cancel_btn.disabled = true
