class_name ProjectileContainer
extends Node2D

const GROUP: String = "projectile_container"


static func get_instance() -> ProjectileContainer:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	return tree.get_first_node_in_group(ProjectileContainer.GROUP) as ProjectileContainer


func _ready() -> void:
	add_to_group(GROUP)
