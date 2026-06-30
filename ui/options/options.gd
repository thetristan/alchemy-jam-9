class_name Options
extends CanvasLayer

@onready var music_icon: TextureRect = %MusicIcon
@onready var music_slider: HSlider = %MusicSlider

@onready var sfx_icon: TextureRect = %SFXIcon
@onready var sfx_slider: HSlider = %SFXSlider

@onready var crt_toggle: CheckButton = %CRTToggle

@onready var save_btn: Button = %Save
@onready var cancel_btn: Button = %Cancel

var _original_music_volume: float
var _original_sfx_volume: float
var _original_crt_enabled: bool

var _music_focused: bool
var _music_hovered: bool
var _sfx_focused: bool
var _sfx_hovered: bool


func _ready() -> void:
	_original_music_volume = GameOptions.music_volume.get_value()
	_original_sfx_volume = GameOptions.sfx_volume.get_value()
	_original_crt_enabled = GameOptions.crt_enabled.get_value()

	music_icon.texture = music_icon.texture.duplicate()
	sfx_icon.texture = sfx_icon.texture.duplicate()

	music_slider.value = GameOptions.music_volume.get_value()
	sfx_slider.value = GameOptions.sfx_volume.get_value()

	music_slider.value_changed.connect(GameOptions.music_volume.set_value)
	music_slider.focus_entered.connect(_set_music_focused.bind(true))
	music_slider.focus_exited.connect(_set_music_focused.bind(false))
	music_slider.mouse_entered.connect(_set_music_hovered.bind(true))
	music_slider.mouse_exited.connect(_set_music_hovered.bind(false))

	sfx_slider.value_changed.connect(GameOptions.sfx_volume.set_value)
	sfx_slider.focus_entered.connect(_set_sfx_focused.bind(true))
	sfx_slider.focus_exited.connect(_set_sfx_focused.bind(false))
	sfx_slider.mouse_entered.connect(_set_sfx_hovered.bind(true))
	sfx_slider.mouse_exited.connect(_set_sfx_hovered.bind(false))

	crt_toggle.button_pressed = GameOptions.crt_enabled.get_value()
	crt_toggle.toggled.connect(GameOptions.crt_enabled.set_value)

	save_btn.pressed.connect(on_save_options)
	cancel_btn.pressed.connect(on_cancel_options)

	save_btn.pressed.connect(func() -> void: Audio.play_sfx(Audio.SFX_UI_ACCEPT))
	cancel_btn.pressed.connect(func() -> void: Audio.play_sfx(Audio.SFX_UI_CANCEL))


func _set_music_focused(value: bool) -> void:
	_music_focused = value
	_update_music_icon()


func _set_music_hovered(value: bool) -> void:
	_music_hovered = value
	_update_music_icon()


func _set_sfx_focused(value: bool) -> void:
	_sfx_focused = value
	_update_sfx_icon()


func _set_sfx_hovered(value: bool) -> void:
	_sfx_hovered = value
	_update_sfx_icon()


func _update_music_icon() -> void:
	music_icon.texture.region.position.x = 2 if _music_focused or _music_hovered else 14
	music_icon.texture.region.position.y = 2


func _update_sfx_icon() -> void:
	sfx_icon.texture.region.position.x = 26 if _sfx_focused or _sfx_hovered else 38
	sfx_icon.texture.region.position.y = 2


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		on_cancel_options()


func on_save_options() -> void:
	GameOptions.save_options()
	_do_hide()


func on_cancel_options() -> void:
	GameOptions.music_volume.set_value(_original_music_volume)
	GameOptions.sfx_volume.set_value(_original_sfx_volume)
	GameOptions.crt_enabled.set_value(_original_crt_enabled)
	crt_toggle.button_pressed = _original_crt_enabled
	_do_hide()


func _do_hide() -> void:
	_disable_buttons()
	SceneManager.pop_scene()


func on_scene_focused() -> void:
	_enable_buttons()
	music_slider.grab_focus()
	_update_music_icon()
	_update_sfx_icon()


func _enable_buttons() -> void:
	music_slider.editable = true
	sfx_slider.editable = true
	crt_toggle.disabled = false
	save_btn.disabled = false
	cancel_btn.disabled = false


func _disable_buttons() -> void:
	music_slider.editable = false
	sfx_slider.editable = false
	crt_toggle.disabled = true
	save_btn.disabled = true
	cancel_btn.disabled = true
