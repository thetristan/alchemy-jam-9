class_name SteamVent
extends AnimatedSprite2D

const MIN_DELAY: float = 3.0
const MAX_DELAY: float = 6.0

@onready var steam_sfx: AudioStreamPlayer2D = $SteamSFX


func _ready() -> void:
	frame_changed.connect(_on_frame_changed)
	_play_loop()


func _play_loop() -> void:
	while is_inside_tree():
		await Util.timer(randf_range(MIN_DELAY, MAX_DELAY), false)
		play()
		await animation_finished


func _on_frame_changed() -> void:
	if frame == 1 or frame == 7:
		steam_sfx.play()
