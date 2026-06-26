class_name Trapper
extends Node2D

const RESET_TIME: float = 2.0

var fsm: TrapperFSM

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var collision_area: Area2D = %CollisionArea
@onready var collider: CollisionShape2D = %Collider

func _ready() -> void:
	fsm = TrapperFSM.new(self)


func _process(delta: float) -> void:
	fsm.process(delta)


func _physics_process(delta: float) -> void:
	fsm.physics_process(delta)


func _unhandled_input(event: InputEvent) -> void:
	fsm.input(event)
