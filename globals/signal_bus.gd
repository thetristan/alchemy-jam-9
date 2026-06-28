extends Node

@warning_ignore_start("unused_signal")
signal lives_changed(lives: int)
signal player_died
signal player_health_changed(health: int, max_health: int)
signal player_restarted_level
@warning_ignore_restore("unused_signal")
