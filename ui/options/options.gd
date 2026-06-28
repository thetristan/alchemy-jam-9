class_name Options
extends CanvasLayer

@onready var music_icon: TextureRect = %MusicIcon
@onready var music_slider: HSlider = %MusicSlider

@onready var sfx_icon: TextureRect = %SFXIcon
@onready var sfx_slider: HSlider = %SFXSlider

@onready var crt_toggle: KeyboardCheckButton = %CRTToggle

@onready var save_btn: KeyboardButton = %Save
@onready var cancel_btn: KeyboardButton = %Cancel

var _original_music_volume: float
var _original_sfx_volume: float
var _original_crt_enabled: bool


func _ready() -> void:
	_original_music_volume = GameOptions.music_volume
	_original_sfx_volume = GameOptions.sfx_volume
	_original_crt_enabled = GameOptions.crt_enabled

	music_icon.texture = music_icon.texture.duplicate()
	sfx_icon.texture = sfx_icon.texture.duplicate()

	music_slider.value = GameOptions.music_volume
	sfx_slider.value = GameOptions.sfx_volume

	music_slider.value_changed.connect(func(value: float): GameOptions.music_volume = value)
	music_slider.focus_entered.connect(_focus_music)
	music_slider.focus_exited.connect(_blur_music)

	sfx_slider.value_changed.connect(func(value: float): GameOptions.sfx_volume = value)
	sfx_slider.focus_entered.connect(_focus_sfx)
	sfx_slider.focus_exited.connect(_blur_sfx)

	crt_toggle.button_pressed = GameOptions.crt_enabled
	crt_toggle.toggled.connect(func(pressed: bool): GameOptions.crt_enabled = pressed)

	save_btn.pressed.connect(on_save_options)
	cancel_btn.pressed.connect(on_cancel_options)


func _focus_music() -> void:
	music_icon.texture.region.position.y = 2


func _blur_music() -> void:
	music_icon.texture.region.position.y = 10


func _focus_sfx() -> void:
	sfx_icon.texture.region.position.y = 2


func _blur_sfx() -> void:
	sfx_icon.texture.region.position.y = 10


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Audio.play_sfx(Audio.SFX_UI_BACK)
		on_cancel_options()


func on_save_options() -> void:
	GameOptions.save_options()
	_do_hide()


func on_cancel_options() -> void:
	GameOptions.music_volume = _original_music_volume
	GameOptions.sfx_volume = _original_sfx_volume
	GameOptions.crt_enabled = _original_crt_enabled
	crt_toggle.button_pressed = _original_crt_enabled
	_do_hide()


func _do_hide() -> void:
	_disable_buttons()
	SceneManager.pop_scene()


func on_scene_focused() -> void:
	_enable_buttons()
	music_slider.grab_focus()
	_focus_music()
	_blur_sfx()


func _enable_buttons() -> void:
	music_slider.editable = true
	sfx_slider.editable = true
	crt_toggle.disabled = false

	save_btn.enable()
	cancel_btn.enable()


func _disable_buttons() -> void:
	music_slider.editable = false
	sfx_slider.editable = false
	crt_toggle.disabled = true

	save_btn.disable()
	cancel_btn.disable()
