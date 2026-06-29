class_name Level
extends Node2D

@export var checkpoints: Array[Checkpoint]


func move_player_to_checkpoint(idx: int) -> void:
	if not checkpoints:
		Log.warn(self, move_player_to_checkpoint, "No checkpoints defined")
		return

	var checkpoint: Checkpoint = checkpoints[clampi(idx, 0, checkpoints.size())]
	checkpoint.active = true

	for other_checkpoint in checkpoints:
		if checkpoint != other_checkpoint:
			other_checkpoint.active = false
