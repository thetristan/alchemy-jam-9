class_name Player
extends CharacterBody2D

static var NOOP_INPUT: PlayerInput = PlayerInputNoop.new()
static var REAL_INPUT: PlayerInput = PlayerInputReal.new()


const DEFAULT_SNAP_LENGTH: float = 4.0
const COYOTE_TIME: float = 0.1
const JUMP_BUFFER_TIME: float = 0.1
const VARIABLE_JUMP_TIME: float = 0.2
const TERMINAL_VELOCITY: float = 400
const JUMP_HEIGHT: float = -260
const LAND_CROUCH_TIME: float = 0.1

const RAIL_SPEED: float = 250
const RAIL_ACCEL_SPEED: float = 500
const RAIL_DECEL_SPEED: float = 500
const RAIL_EXCLUSION_TIME: float = 0.2
const RAIL_TILT_ACCEL_SPEED: float = 15
const RAIL_TILT_DECEL_SPEED: float = 60

const GROUND_SPEED: float = 200
const AIR_SPEED: float = 150
const ACCEL_SPEED: float = 1000
const DECEL_SPEED: float = 2200
const STRETCH_SPEED: float = 150

const MAX_HEIGHT: float = 128
const MIN_HEIGHT: float = 48


@export var disable_real_input: bool

var was_on_floor: bool
var was_dropped: bool
var landed: bool
var direction: float
var last_direction: float
var current_speed: float
var coyote_time_remaining: float
var jump_buffer_time_remaining: float

var attached_rail: Rail

var height: float = MIN_HEIGHT:
	set(new_val):
		if height == round(new_val):
			return

		height = round(new_val)

		if not is_node_ready():
			return

		_update_height()


var fsm: PlayerFSM

var input: PlayerInput:
	get: return input_queue.front() if not input_queue.is_empty() else base_input
	set(new_val): pass

var base_input: PlayerInput:
	get: return NOOP_INPUT if disable_real_input else REAL_INPUT
	set(new_val): pass

var input_queue: Array[PlayerInput] = []


@onready var wheel_collider: CollisionShape2D = %WheelCollider
@onready var world_collider: CollisionShape2D = %WorldCollider
@onready var attach_ray_cast: RayCast2D = %AttachRayCast
@onready var hit_box: Area2D = %HitBox
@onready var hit_box_collider: CollisionShape2D = %HitBoxCollider
@onready var rail_follower: PathFollow2D = %RailFollower
@onready var wheel_sprite: AnimatedSprite2D = %WheelSprite
@onready var sprite: AnimatedSprite2D = %Sprite
@onready var sprite_group: CanvasGroup = %SpriteGroup


func _ready() -> void:
	# Disable wheel collisions for now
	wheel_collider.disabled = true

	# Hide sprites
	wheel_sprite.hide()

	fsm = PlayerFSM.new(self)
	fsm.transitioned.connect(func(from, to) -> void:
		Log.debug(self, Callable(), "Player: %s -> %s" % [from, to]))
 

func _update_height() -> void:
	pass


func _process(delta: float) -> void:
	fsm.process(delta)


func _physics_process(delta: float) -> void:
	_update_input(delta)
	fsm.physics_process(delta)

	# Snap to floor
	if is_on_floor():
		global_position.y = roundf(global_position.y)


func _unhandled_input(event: InputEvent) -> void:
	fsm.input(event)


func _update_input(delta: float) -> void:
	input.update(delta)
	while not input_queue.is_empty() and input.is_finished():
		if not is_zero_approx(input.move.x):
			direction = signf(input.move.x)
		input_queue.pop_front()
		input.update(delta)


func push_input(scripted_input: PlayerInput) -> void:
	input_queue.push_back(scripted_input)


func hit(direction: Vector2) -> void:
	fsm.transition_to_hit_state(direction)
