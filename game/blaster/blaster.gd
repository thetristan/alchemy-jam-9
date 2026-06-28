class_name Blaster
extends Node2D

@export var auto: bool = true
@export var face_left: bool = true
@export var delay: float

var fsm: BlasterFSM
var _fire_direction: Vector2 = Vector2.LEFT

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var projectile_spawn: Marker2D = %ProjectileSpawn
@onready var on_screen_notifier: VisibleOnScreenNotifier2D = %OnScreenNotifier
@onready var fire_sfx: AudioStreamPlayer2D = %FireSFX


func _ready() -> void:
	fsm = BlasterFSM.new(self)

	if not face_left:
		sprite.flip_h = true
		sprite.offset.x *= -1
		projectile_spawn.position.x *= -1
		_fire_direction = Vector2.RIGHT


func _process(delta: float) -> void:
	fsm.process(delta)


func _physics_process(delta: float) -> void:
	fsm.physics_process(delta)


func _unhandled_input(event: InputEvent) -> void:
	fsm.input(event)


func fire() -> void:
	if fsm.current_state == fsm.idle_state:
		fsm.transition_to_firing_state()
