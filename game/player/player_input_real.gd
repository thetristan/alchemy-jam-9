class_name PlayerInputReal
extends PlayerInput


func update(_delta: float) -> void:
	move = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	jump_pressed = Input.is_action_pressed("jump")
	jump_just_pressed = Input.is_action_just_pressed("jump")
	stretch_pressed = Input.is_action_pressed("stretch")
	stretch_just_pressed = Input.is_action_just_pressed("stretch")
