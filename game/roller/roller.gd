class_name Roller
extends CharacterBody2D

const ROLL_SPEED: float = 300
const ROLL_ACCEL: float = 1000

@export var face_left: bool

var fsm: RollerFSM
var direction: float = 1

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var world_collider: CollisionShape2D = %WorldCollider
@onready var upper_player_ray_cast: RayCast2D = %UpperPlayerRayCast
@onready var lower_player_ray_cast: RayCast2D = %LowerPlayerRayCast
@onready var hit_box: Area2D = %HitBox
@onready var hit_box_collider: CollisionShape2D = %HitBoxCollider

func _ready() -> void:
	if face_left:
		sprite.flip_h = true
		sprite.offset.x *= -1
		upper_player_ray_cast.target_position.x *= -1
		lower_player_ray_cast.target_position.x *= -1
		direction = -1
		

	fsm = RollerFSM.new(self)


func _process(delta: float) -> void:
	fsm.process(delta)


func _physics_process(delta: float) -> void:
	fsm.physics_process(delta)


func _unhandled_input(event: InputEvent) -> void:
	fsm.input(event)
