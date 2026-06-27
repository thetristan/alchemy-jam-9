class_name Blaster
extends Node2D

@export var face_left: bool = true

var fsm: BlasterFSM

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var projectile_spawn: Marker2D = %ProjectileSpawn


func _ready() -> void:
	fsm = BlasterFSM.new(self)


func _process(delta: float) -> void:
	fsm.process(delta)


func _physics_process(delta: float) -> void:
	fsm.physics_process(delta)


func _unhandled_input(event: InputEvent) -> void:
	fsm.input(event)


func fire() -> void:
	if fsm.current_state == fsm.idle_state:
		fsm.transition_to_firing_state()
