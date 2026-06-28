class_name Spinner
extends Node2D

const SPIN_SPEED: float = 250
const TARGETING_DELAY: float = 0.5
const DAMAGE_AMOUNT: int = 1
const KNOCKBACK_AMOUNT: float = 400

var fsm: SpinnerFSM

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var target_sprite: AnimatedSprite2D = %TargetSprite
@onready var hit_box: Area2D = %HitBox
@onready var hit_box_collider: CollisionShape2D = %HitBoxCollider
@onready var player_detection: Area2D = %PlayerDetection
@onready var detection_collider: CollisionShape2D = %DetectionCollider
@onready var roll_whoosh_sfx: AudioStreamPlayer2D = %RollWhooshSFX
@onready var player_sighted_sfx: AudioStreamPlayer2D = %PlayerSightedSFX
@onready var explode_sfx: AudioStreamPlayer2D = %ExplodeSFX


func _ready() -> void:
	# Initial node setup
	target_sprite.hide()

	fsm = SpinnerFSM.new(self)


func _process(delta: float) -> void:
	fsm.process(delta)


func _physics_process(delta: float) -> void:
	fsm.physics_process(delta)


func _unhandled_input(event: InputEvent) -> void:
	fsm.input(event)
