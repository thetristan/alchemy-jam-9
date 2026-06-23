@tool
@icon("res://addons/triggers/icons/trigger-icon-moving.svg")
class_name TweenTrigger
extends Trigger

@export var target_nodes: Array[Node]
@export var target_property: NodePath
@export var target_value: Variant

@export var tween_easing: Tween.EaseType
@export var tween_transition: Tween.TransitionType
@export var duration: float = 2.0

var tweens: Array[Tween]

func valid_config() -> bool:
	var result: bool = super.valid_config()

	if not target_nodes:
		Log.error(self , valid_config, "Missing target nodes")
		result = false

	return result


func trigger() -> void:
	if not can_trigger():
		return

	if tweens:
		for tween in tweens:
			tween.kill()

	# Create on the target_node since this node will be paused
	var tween: Tween
	for target_node in target_nodes:
		tween = target_node.create_tween()
		tween.set_ease(tween_easing)
		tween.set_trans(tween_transition)
		tween.tween_property(target_node, target_property, target_value, duration)
		tweens.append(tween)

	# Await last tween
	await tween.finished
	super.trigger()
