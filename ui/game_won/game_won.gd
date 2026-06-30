class_name GameWon
extends CanvasLayer

@onready var quit_btn: Button = %MainMenu


func on_start_game() -> void:
	_disable_button()
	SceneManager.replace_with_game_scene()


func on_quit_game() -> void:
	_disable_button()
	SceneManager.replace_with_title_scene()


func _ready() -> void:
	get_tree().paused = false
	Audio.play_music(Audio.MUSIC_GAME_WON)
	quit_btn.pressed.connect(on_quit_game)
	quit_btn.pressed.connect(func() -> void: Audio.play_sfx(Audio.SFX_UI_ACCEPT))
	_enable_button()


func on_blur() -> void:
	_disable_button()
	

func on_focus() -> void:
	_enable_button()


func _enable_button() -> void:
	quit_btn.disabled = false
	quit_btn.focus_mode = Control.FOCUS_ALL
	quit_btn.grab_focus()
	

func _disable_button() -> void:
	quit_btn.disabled = true
	quit_btn.focus_mode = Control.FOCUS_NONE
