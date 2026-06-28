class_name HealthBar
extends TextureProgressBar


func _ready() -> void:
	SignalBus.player_health_changed.connect(_update_health)


func _update_health(health: int, max_health: int) -> void:
	value = health
	max_value = max_health
