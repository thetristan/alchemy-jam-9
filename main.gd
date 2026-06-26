class_name Main
extends Node2D


func _ready() -> void:
	get_tree().paused = false
	SceneManager.init(self)

	RenderingServer.set_default_clear_color(Palette.DARK_BLUE_COLOR)

	if GameOptions.debug_mode:
		SceneManager.replace_with_game_scene()
