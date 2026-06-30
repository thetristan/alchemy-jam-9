class_name GameOver
extends CanvasLayer

var time_left: int:
	set(new_val):
		time_left = new_val
		if not is_node_ready():
			return
		time_counter.time_left = time_left

@onready var play_btn: Button = %PlayAgain
@onready var quit_btn: Button = %MainMenu
@onready var time_counter: TimeCounter = %TimeCounter
@onready var buttons: Array[Button] = [
	play_btn,
	quit_btn
]

func on_start_game() -> void:
	_disable_buttons()
	SceneManager.replace_with_game_scene()


func on_quit_game() -> void:
	_disable_buttons()
	SceneManager.replace_with_title_scene()


func _ready() -> void:
	get_tree().paused = false
	time_counter.time_left = time_left
	Audio.play_music(Audio.MUSIC_GAME_OVER)
	play_btn.pressed.connect(on_start_game)
	quit_btn.pressed.connect(on_quit_game)
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
