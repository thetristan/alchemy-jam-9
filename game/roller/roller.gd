class_name Roller
extends CharacterBody2D

const ROLL_SPEED: float = 300
const ROLL_ACCEL: float = 1000
const DAMAGE_AMOUNT: int = 4
const KNOCKBACK_AMOUNT: float = 800

@export var face_left: bool
@export var volume_scale: float = 1.0

var fsm: RollerFSM
var direction: float = 1

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var world_collider: CollisionShape2D = %WorldCollider
@onready var upper_player_ray_cast: RayCast2D = %UpperPlayerRayCast
@onready var lower_player_ray_cast: RayCast2D = %LowerPlayerRayCast
@onready var hit_box: Area2D = %HitBox
@onready var hit_box_collider: CollisionShape2D = %HitBoxCollider
@onready var roll_sfx: AudioStreamPlayer2D = %RollSFX
@onready var roll_whoosh_sfx: AudioStreamPlayer2D = %RollWhooshSFX
@onready var player_sighted_sfx: AudioStreamPlayer2D = %PlayerSightedSFX
@onready var explode_sfx: AudioStreamPlayer2D = %ExplodeSFX

func _ready() -> void:
	if face_left:
		sprite.flip_h = true
		sprite.offset.x *= -1
		upper_player_ray_cast.target_position.x *= -1
		lower_player_ray_cast.target_position.x *= -1
		direction = -1

	for sfx: AudioStreamPlayer2D in [roll_sfx, roll_whoosh_sfx, player_sighted_sfx, explode_sfx]:
		sfx.volume_linear *= volume_scale

	fsm = RollerFSM.new(self)


func _process(delta: float) -> void:
	fsm.process(delta)


func _physics_process(delta: float) -> void:
	fsm.physics_process(delta)


func _unhandled_input(event: InputEvent) -> void:
	fsm.input(event)
