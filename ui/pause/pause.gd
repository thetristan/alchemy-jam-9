class_name Pause
extends CanvasLayer

@onready var resume_btn: Button = %Resume
@onready var options_btn: Button = %Options
@onready var quit_btn: Button = %Quit

@onready var buttons: Array[Button] = [
	resume_btn,
	options_btn,
	quit_btn
]

var _focused: bool = false


func _ready() -> void:
	resume_btn.pressed.connect(on_pause_hide)
	quit_btn.pressed.connect(SceneManager.replace_with_title_scene)
	options_btn.pressed.connect(SceneManager.push_options_scene)


func on_pause_hide() -> void:
	_disable_buttons()
	SceneManager.pop_scene()


func _unhandled_input(_event: InputEvent) -> void:
	if _focused and Input.is_action_just_pressed("ui_cancel"):
		on_pause_hide()


func on_focus() -> void:
	await get_tree().process_frame
	_focused = true
	_enable_buttons()
	
	
func on_blur() -> void:
	_focused = false
	_disable_buttons()


func _disable_buttons() -> void:
	for b in buttons:
		b.disabled = true
		b.focus_mode = Control.FOCUS_NONE


func _enable_buttons() -> void:
	for b in buttons:
		b.disabled = false
		b.focus_mode = Control.FOCUS_ALL

	resume_btn.grab_focus()
