class_name QuakeParticles
extends GPUParticles2D


func _process(_delta: float) -> void:
	var player: Player = Player.get_instance()
	if player:
		global_position.x = player.global_position.x


func _ready() -> void:
	%QuakeTrigger.trigger()
