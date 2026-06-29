extends Node2D

@export var particle_process_materials: Array[ParticleProcessMaterial]
@onready var particle_loader: GPUParticles2D = %ParticleLoader


func _ready() -> void:
	for mat in particle_process_materials:
		particle_loader.process_material = mat
		particle_loader.emitting = true
		await get_tree().process_frame
		
	particle_loader.emitting = false
