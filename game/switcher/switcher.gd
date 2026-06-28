class_name Switcher
extends Node2D

@export var trigger: Trigger

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var trigger_area: Area2D = %Trigger
@onready var trigger_collider: CollisionShape2D = %Collider

func _ready() -> void:
	trigger_area.area_entered.connect(_on_switched)

func _on_switched(_area: Area2D) -> void:
	trigger_collider.set_deferred("disabled", true)

	if trigger:
		trigger.trigger()

	sprite.play("on")
