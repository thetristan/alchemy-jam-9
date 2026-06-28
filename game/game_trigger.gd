@tool
@icon("res://addons/triggers/icons/trigger-icon.svg")
class_name GameTrigger
extends Trigger

enum Action {
	INCREASE_LIVES,
}

@export var action: Action = Action.INCREASE_LIVES
@export var amount: int = 1


func _do_trigger() -> void:
	var game: Game = Game.get_instance()
	if not game:
		Log.error(self, _do_trigger, "No game found")
		return

	match action:
		Action.INCREASE_LIVES:
			game.add_lives(amount)

	super._do_trigger()
