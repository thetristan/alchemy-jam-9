class_name Game
extends Node2D


func on_blur() -> void:
	get_tree().paused = true


func on_focus() -> void:
	get_tree().paused = false


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		SceneManager.push_paused_scene()
