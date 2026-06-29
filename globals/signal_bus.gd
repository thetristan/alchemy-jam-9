extends Node

@warning_ignore_start("unused_signal")
signal lives_changed(lives: int)
signal seconds_elapsed(seconds_left: int)
signal player_dying
signal player_died
signal player_health_changed(health: int, max_health: int)
signal player_restarted_level
signal player_checkpoint_reached(checkpoint_id: StringName)
@warning_ignore_restore("unused_signal")
