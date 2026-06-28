class_name Title
extends CanvasLayer

@onready var play_btn: Button = %Play
@onready var options_btn: Button = %Options

@onready var buttons: Array[Button] = [
	play_btn,
	options_btn
]

func on_start_game() -> void:
	_disable_buttons()
	SceneManager.replace_with_game_scene()


func on_options_show() -> void:
	SceneManager.push_options_scene()


func _ready() -> void:
	get_tree().paused = false
	Audio.play_music(Audio.MUSIC_MAIN_MENU)
	play_btn.pressed.connect(on_start_game)
	options_btn.pressed.connect(on_options_show)
	_enable_buttons()


func on_blur() -> void:
	_disable_buttons()
	

func on_focus() -> void:
	_enable_buttons()


func _enable_buttons() -> void:
	for b in buttons:
		b.disabled = false
		b.focus_mode = Control.FOCUS_ALL

	play_btn.grab_focus()
	

func _disable_buttons() -> void:
	for b in buttons:
		b.disabled = true
		b.focus_mode = Control.FOCUS_NONE
