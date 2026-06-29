class_name Switcher
extends Node2D

@export var trigger: Trigger

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var trigger_area: Area2D = %Trigger
@onready var trigger_collider: CollisionShape2D = %Collider
@onready var on_sfx: AudioStreamPlayer2D = %OnSFX

func _ready() -> void:
	trigger_area.area_entered.connect(_on_switched)

func _on_switched(_area: Area2D) -> void:
	trigger_collider.set_deferred("disabled", true)

	if trigger:
		trigger.trigger()

	sprite.play("on")
	on_sfx.play()


# Silently toggle whether the switch can be pressed, without playing the
# "on" animation or sound effect.
func set_switch_enabled(value: bool) -> void:
	trigger_collider.set_deferred("disabled", not value)


# Silently set the switch display to its on (last frame) or off (first frame)
# state without playing the animation or sound effect.
func set_display_on(value: bool) -> void:
	sprite.stop()
	sprite.animation = "on"
	sprite.frame = sprite.sprite_frames.get_frame_count("on") - 1 if value else 0
