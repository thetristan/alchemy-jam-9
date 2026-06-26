@tool
@icon("res://components/triggers/icons/trigger-icon.svg")
class_name PlayerInputTrigger
extends Trigger

@export var player: Player
@export var move: Vector2
@export var duration: float
@export var jump: bool
@export var stretch: bool


func valid_config() -> bool:
	if player == null:
		Log.debug(self, valid_config, "player is null")
		return false

	return true


func _do_trigger() -> void:
	player.push_input(PlayerInputScripted.new(move, duration, stretch, jump))

	super._do_trigger()
