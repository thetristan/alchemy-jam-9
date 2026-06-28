@tool
@icon("res://addons/triggers/icons/trigger-icon.svg")
class_name AreaTrigger
extends Area2D

@export var trigger: Trigger


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)


func _on_area_entered(_area: Area2D) -> void:
	if trigger:
		trigger.trigger()


func _on_body_entered(_node: Node2D) -> void:
	if trigger:
		trigger.trigger()
