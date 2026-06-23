@tool
@icon("res://addons/triggers/icons/trigger-icon.svg")
class_name AreaTrigger
extends Area2D

@export var trigger: Trigger


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	body_entered.connect(_on_body_entered)


func _on_body_entered(_node: Node2D) -> void:
	if trigger:
		trigger.trigger()
