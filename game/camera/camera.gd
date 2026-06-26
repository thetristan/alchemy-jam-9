extends Camera2D

const CAMERA_SPEED: float = 400

@export var target_node: Node2D


func _physics_process(delta: float) -> void:
	if target_node:
		global_position = global_position.move_toward(target_node.global_position, CAMERA_SPEED * delta)
