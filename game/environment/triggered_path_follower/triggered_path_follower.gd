class_name TriggeredPathFollower
extends PathFollow2D

signal move_finished

@export var easing: Tween.EaseType = Tween.EASE_IN_OUT
@export var transition: Tween.TransitionType = Tween.TRANS_SINE
@export var move_sfx: AudioStreamPlayer2D


var movement_tween: Tween

func _ready() -> void:
	pass


func move_to(ratio: float, duration: float = 2.0) -> void:
	if movement_tween:
		movement_tween.kill()
	movement_tween = create_tween()
	movement_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	movement_tween.set_ease(easing)
	movement_tween.set_trans(transition)
	movement_tween.tween_property(self , "progress_ratio", ratio, duration)
	movement_tween.finished.connect(move_finished.emit)
	if move_sfx:
		move_sfx.play()
