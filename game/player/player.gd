class_name Player
extends CharacterBody2D


const GROUP: String = "player"

static var NOOP_INPUT: PlayerInput = PlayerInputNoop.new()
static var REAL_INPUT: PlayerInput = PlayerInputReal.new()

static func get_instance() -> Player:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if not tree:
		return null

	return tree.get_first_node_in_group(GROUP) as Player


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
const RAIL_SPARK_BURST_TIME: float = 0.1
const RAIL_SPARK_MIN_SPEED: float = 5.0

const GROUND_SPEED: float = 200
const AIR_SPEED: float = 150
const ACCEL_SPEED: float = 1000
const DECEL_SPEED: float = 2200
const STRETCH_SPEED: float = 150

const MAX_HEIGHT: float = 128
const MIN_HEIGHT: float = 48

const MAX_HEALTH: int = 12

@export var disable_real_input: bool

var dead: bool:
	get:
		return fsm.current_state in [fsm.dying_state, fsm.dead_state]

var was_on_floor: bool
var was_dropped: bool
var landed: bool
var direction: float
var last_direction: float
var current_speed: float
var coyote_time_remaining: float
var jump_buffer_time_remaining: float
var knockback_velocity: Vector2
var knockback_duration: float

var attached_rail: Rail

var health: int = MAX_HEALTH:
	set(new_val):
		if health == new_val:
			return

		health = clampi(new_val, 0, MAX_HEALTH)
		SignalBus.player_health_changed.emit(health, MAX_HEALTH)
		if health == 0:
			fsm.transition_to_dying_state()


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

var disable_signal: bool

@onready var wheel_collider: CollisionShape2D = %WheelCollider
@onready var world_collider: CollisionShape2D = %WorldCollider
@onready var attach_ray_cast: RayCast2D = %AttachRayCast
@onready var hit_box: Area2D = %HitBox
@onready var hit_box_collider: CollisionShape2D = %HitBoxCollider
@onready var rail_follower: PathFollow2D = %RailFollower
@onready var wheel_sprite: AnimatedSprite2D = %WheelSprite
@onready var sprite: AnimatedSprite2D = %Sprite
@onready var sprite_group: CanvasGroup = %SpriteGroup
@onready var knockback_origin: Marker2D = %KnockbackOrigin
@onready var arrow_sprite: AnimatedSprite2D = %ArrowSprite
@onready var spark_left: GPUParticles2D = %SparkLeft
@onready var spark_right: GPUParticles2D = %SparkRight

@onready var jump_sfx: AudioStreamPlayer2D = %JumpSFX
@onready var land_sfx: AudioStreamPlayer2D = %LandSFX
@onready var hit_sfx: AudioStreamPlayer2D = %HitSFX
@onready var death_sfx: AudioStreamPlayer2D = %DeathSFX
@onready var attach_to_rail_sfx: AudioStreamPlayer2D = %AttachToRailSFX
@onready var detach_from_rail_sfx: AudioStreamPlayer2D = %DetachFromRailSFX


func _ready() -> void:
	add_to_group(GROUP)

	wheel_collider.disabled = true
	wheel_sprite.hide()

	fsm = PlayerFSM.new(self)
	fsm.transitioned.connect(func(from, to) -> void:
		Log.debug(self, Callable(), "Player: %s -> %s" % [from, to]))

	SignalBus.player_health_changed.emit(health, MAX_HEALTH)
 

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

	# Show arrow if out of frame
	arrow_sprite.global_position.x = global_position.x

	if global_position.y <= -38:
		if not arrow_sprite.visible:
			arrow_sprite.show()
			arrow_sprite.play()
	elif arrow_sprite.visible:
		arrow_sprite.play_backwards()
		await arrow_sprite.animation_finished
		arrow_sprite.hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		if fsm.current_state == fsm.debug_state:
			fsm.transition_to_idle_state()
		elif fsm.current_state not in [fsm.dying_state, fsm.dead_state, fsm.disabled_state]:
			fsm.transition_to_debug_state()
		return

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


func enable() -> void:
	fsm.transition_to_idle_state()


func disable() -> void:
	fsm.transition_to_disabled_state()


func kill() -> void:
	health = 0


func add_health(amount: int) -> void:
	health += amount


func hit(amount: int, damage_origin: Vector2, force: float, duration: float = 0.2) -> void:
	if fsm.current_state in [fsm.hit_state, fsm.dying_state]:
		return

	health -= amount

	var knockback_direction: Vector2 = knockback_origin.global_position.direction_to(damage_origin)
	knockback_duration += duration
	knockback_velocity = knockback_direction * force
	fsm.transition_to_hit_state()
