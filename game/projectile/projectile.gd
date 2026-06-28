class_name Projectile
extends Area2D

const DAMAGE_AMOUNT: int = 3
const SPEED: float = 150

var _direction: Vector2 = Vector2(1, 0)
var _live: bool

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var collider: CollisionShape2D = %Collider
@onready var on_screen_notifier: VisibleOnScreenNotifier2D = %OnScreenNotifier

static var SCENE: PackedScene = preload("res://game/projectile/projectile.tscn")
static func spawn(at: Vector2, direction: Vector2) -> Projectile:
	var container: ProjectileContainer = ProjectileContainer.get_instance()
	if not container:
		return
		
	var instance: Projectile = SCENE.instantiate()
	container.add_child(instance)
	instance.global_position = at
	instance._direction = direction
	return instance


func _ready() -> void:
	_live = true
	sprite.play("default")
	area_entered.connect(_on_hit)
	on_screen_notifier.screen_exited.connect(queue_free)


func _physics_process(delta: float) -> void:
	if _live:
		global_position += _direction * SPEED * delta


func _on_hit(area: Area2D) -> void:
	_live = false
	await get_tree().process_frame
	var player_hit_box: PlayerHitBox = area as PlayerHitBox
	if player_hit_box:
		player_hit_box.hit(DAMAGE_AMOUNT, global_position, 400)

	sprite.play("explode")
	await sprite.animation_finished
	queue_free()
