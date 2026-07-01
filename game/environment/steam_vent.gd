class_name SteamVent
extends AnimatedSprite2D

@onready var steam_sfx: AudioStreamPlayer2D = $SteamSFX


func _ready() -> void:
	frame_changed.connect(_on_frame_changed)


func _on_frame_changed() -> void:
	if frame == 1 or frame == 7:
		steam_sfx.play()
