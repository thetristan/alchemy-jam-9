class_name Checkpoint
extends Node2D

@export var id: StringName
@export var active: bool:
	set(new_val):
		active = new_val
		if not is_node_ready():
			return
		if active:
			if trigger:
				trigger.trigger()

			PaletteShader.get_instance().brightness = 0.5
			sprite.play("on")
			await sprite.animation_finished
			PaletteShader.get_instance().brightness = 0
			sprite.play("on_idle")
		else:
			sprite.play_backwards("on")
			await sprite.animation_finished
			sprite.play("off_idle")

@export var trigger: Trigger
@export var enabled: bool

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var spawn_marker: Marker2D = %SpawnMarker
@onready var trigger_area: Area2D = %TriggerArea
@onready var trigger_collider: CollisionShape2D = %TriggerCollider
@onready var message: Label = %Message
@onready var reached_sfx: AudioStreamPlayer2D = %ReachedSFX


func _ready() -> void:
	trigger_collider.disabled = not enabled
	trigger_area.area_entered.connect(_on_area_entered)
	SignalBus.player_checkpoint_reached.connect(_disable_self)
	message.hide()
	sprite.play("on_idle" if active else "off_idle")


func get_spawn_location() -> Vector2:
	return spawn_marker.global_position


func _on_area_entered(area: Area2D) -> void:
	if active:
		return

	var player_hit_box: PlayerHitBox = area as PlayerHitBox
	if not player_hit_box:
		return

	active = true
	SignalBus.player_checkpoint_reached.emit(id)

	reached_sfx.play()
	message.show()
	await Util.timer(2.0)
	message.hide()


func _disable_self(checkpoint_id: StringName) -> void:
	if checkpoint_id == id:
		return
	active = false
