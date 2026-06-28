class_name Trapper
extends Node2D

const DAMAGE_AMOUNT: int = 2
const KNOCKBACK_AMOUNT: float = 400
const RESET_TIME: float = 2
const IDLE_JIGGLE_MIN_DELAY: float = 0.5
const IDLE_JIGGLE_MAX_DELAY: float = 2.5

var fsm: TrapperFSM

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var trigger: Area2D = %Trigger
@onready var collider: CollisionShape2D = %Collider
@onready var hit_box: Area2D = %HitBox
@onready var hit_box_collider: CollisionPolygon2D = %HitBoxCollider
@onready var snap_sfx: AudioStreamPlayer2D = %SnapSFX


func _ready() -> void:
	fsm = TrapperFSM.new(self)


func _process(delta: float) -> void:
	fsm.process(delta)


func _physics_process(delta: float) -> void:
	fsm.physics_process(delta)


func _unhandled_input(event: InputEvent) -> void:
	fsm.input(event)
