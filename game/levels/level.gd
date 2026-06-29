class_name Level
extends Node2D

@export var checkpoints: Array[Checkpoint]

@onready var player: Player = %Player
@onready var camera: BleazyCam = %Camera2D


func move_player_to_checkpoint(id: StringName) -> void:
	if not checkpoints:
		Log.warn(self, move_player_to_checkpoint, "No checkpoints defined")
		return

	var idx: int = checkpoints.find_custom(func(c: Checkpoint) -> bool: return c.id == id)
	if idx < 0:
		Log.warn(self, move_player_to_checkpoint, "No found with id %s" % id)
		return

	var checkpoint: Checkpoint = checkpoints[idx]
	checkpoint.active = true

	var spawn_location: Vector2 = checkpoint.get_spawn_location()
	player.global_position = spawn_location
	camera.global_position = spawn_location
