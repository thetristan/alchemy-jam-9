class_name BleazyCam
extends Camera2D


const GROUP: String = "camera"
const CAMERA_SPEED: float = 400

@export var target_node: Node2D

@export_group("Shake")
@export var decay: float = 0.6 # How quickly shaking will stop [0,1].
@export var max_offset: Vector2 = Vector2(16, 16) # Maximum displacement in pixels.
@export var noise: Noise # The source of random values.


var noise_y: float = 0 # Value used to move through the noise
var trauma: float = 0.0 # Current shake strength
var trauma_pwr: float = 3 # Trauma exponent. Use [2,3]


static func get_instance() -> BleazyCam:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if not tree:
		return null
	return tree.get_first_node_in_group(GROUP) as BleazyCam


static func get_and_add_trauma(amount: float) -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if not tree:
		return
	BleazyCam.get_instance().add_trauma(amount)


func _ready() -> void:
	add_to_group(GROUP)


func add_trauma(amount: float) -> void:
	trauma += amount


func _physics_process(delta: float) -> void:
	if target_node:
		global_position = global_position.move_toward(target_node.global_position, CAMERA_SPEED * delta)

	apply_trauma(delta)


func apply_trauma(delta: float) -> void:
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		var amt = pow(trauma, trauma_pwr)
		noise_y += 1
		
		var nx = noise.get_noise_2d(noise.seed * 2, noise_y)
		var ny = noise.get_noise_2d(noise.seed * 3, noise_y)
		
		offset.x = max_offset.x * amt * nx
		offset.y = max_offset.y * amt * ny
