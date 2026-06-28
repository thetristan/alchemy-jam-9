@tool
@icon("res://addons/triggers/icons/trigger-icon.svg")
class_name PlayerTrigger
extends Trigger

enum Action {
	KILL,
	INCREASE_HEALTH,
}

@export var action: Action = Action.KILL
@export var amount: int = 1


func _do_trigger() -> void:
	var player: Player = Player.get_instance()
	if not player:
		Log.error(self, _do_trigger, "No player found")
		return

	match action:
		Action.KILL:
			player.kill()
		Action.INCREASE_HEALTH:
			player.add_health(amount)

	super._do_trigger()
