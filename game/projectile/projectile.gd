class_name Projectile
extends Area2D

const SPEED: float = 250

var direction: Vector2 = Vector2(1, 0)

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var collider: CollisionShape2D = %Collider


static var SCENE: PackedScene = preload("res://game/projectile/projectile.tscn")
static func spawn(at: Vector2, direction_: Vector2) -> Projectile:
	var instance: Projectile = SCENE.instantiate()
	instance.global_position = at
	instance.direction = direction_
	return instance


func _physics_process(delta: float) -> void:
	global_position += direction * SPEED * delta
