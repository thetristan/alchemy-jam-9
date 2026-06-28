@tool
@icon("res://addons/triggers/icons/trigger-icon.svg")
class_name AnimationTrigger
extends Trigger
## Plays an animation on the target AnimatedSprite2D, then continues the
## trigger chain once the animation has finished.

@export var target: AnimatedSprite2D
@export var animation: StringName


func valid_config() -> bool:
	var result: bool = super.valid_config()

	if not target:
		Log.error(self , valid_config, "Missing target")
		result = false

	if target and target.sprite_frames and not target.sprite_frames.has_animation(animation):
		Log.error(self , valid_config, "Target has no animation named '%s'" % animation)
		result = false

	return result


func trigger() -> void:
	if not can_trigger():
		return

	target.play(animation)
	await target.animation_finished
	super.trigger()
