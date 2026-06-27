class_name Smasher
extends CharacterBody2D

var fsm: SmasherFSM

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var collider: CollisionShape2D = %Collider
@onready var player_ray_cast: RayCast2D = %PlayerRayCast
@onready var world_ray_cast: RayCast2D = %WorldRayCast
@onready var hit_box: Area2D = %HitBox
@onready var hit_box_collider: CollisionShape2D = %HitBoxCollider


func _ready() -> void:
	fsm = SmasherFSM.new(self)


func _process(delta: float) -> void:
	fsm.process(delta)


func _physics_process(delta: float) -> void:
	fsm.physics_process(delta)


func _unhandled_input(event: InputEvent) -> void:
	fsm.input(event)
