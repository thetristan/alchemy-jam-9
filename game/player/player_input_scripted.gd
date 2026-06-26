class_name PlayerInputScripted
extends PlayerInput

var duration: float
var _first_frame: bool


func _init(move_: Vector2 = Vector2.ZERO, duration_: float = 0.0, stretch_: bool = false, jump_: bool = false) -> void:
	move = move_
	duration = duration_
	stretch_pressed = stretch_
	stretch_just_pressed = stretch_
	_first_frame = jump_ or stretch_
	jump_pressed = jump_
	jump_just_pressed = jump_


func update(delta: float) -> void:
	duration -= delta
	if _first_frame:
		_first_frame = false
	else:
		jump_just_pressed = false
		stretch_just_pressed = false


func is_finished() -> bool:
	return duration <= 0.0
