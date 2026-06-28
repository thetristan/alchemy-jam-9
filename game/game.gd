class_name Game
extends Node2D

static var LEVEL_SCENE: PackedScene = preload("res://game/levels/level_1.tscn")
var level: Node


func _ready() -> void:
	StaticFX.get_instance().coverage = 0
	load_level()


func on_blur() -> void:
	get_tree().paused = true


func on_focus() -> void:
	get_tree().paused = false


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		SceneManager.push_paused_scene()


func load_level() -> void:
	if level:
		level.queue_free()

	level = LEVEL_SCENE.instantiate()
	add_child(level)
