@tool
@icon("res://addons/triggers/icons/trigger-icon.svg")
class_name PlayerTrigger
extends Trigger

enum Action {
	KILL,
}

@export var action: Action = Action.KILL


func trigger() -> void:
	var player: Player = Player.get_instance()
	if not player:
		Log.error(self, trigger, "No player found")

	match action:
		Action.KILL:
			player.kill()
