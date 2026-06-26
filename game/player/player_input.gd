class_name PlayerInput
extends RefCounted

var move: Vector2
var stretch_pressed: bool
var stretch_just_pressed: bool
var jump_pressed: bool
var jump_just_pressed: bool

var move_direction: float:
	get: return move.x
var move_left: bool:
	get: return move.x < 0
var move_right: bool:
	get: return move.x > 0
var down_strength: float:
	get: return move.y
var moving: bool:
	get: return not is_zero_approx(move.x)


func update(_delta: float) -> void:
	pass


func is_finished() -> bool:
	return false
