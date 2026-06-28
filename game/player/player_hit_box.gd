class_name PlayerHitBox
extends Area2D


func hit(amount: int, knockback_origin: Vector2, force: float) -> void:
	var player: Player = get_parent() as Player
	if player:
		player.hit(amount, knockback_origin, force)
