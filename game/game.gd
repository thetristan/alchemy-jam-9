class_name Game
extends Node2D

const GROUP: String = "game"

const STARTING_LIVES: int = 5
const MAX_LIVES: int = 99

static func get_instance() -> Game:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if not tree:
		return null

	return tree.get_first_node_in_group(GROUP) as Game


static var LEVEL_SCENE: PackedScene = preload("res://game/levels/level_1.tscn")
var level: Node

var lives: int = STARTING_LIVES:
	set(new_val):
		if lives == new_val:
			return

		lives = clampi(new_val, 0, MAX_LIVES)
		SignalBus.lives_changed.emit(lives)


@onready var lives_counter_container: PanelContainer = %LivesCounterContainer
@onready var lives_counter: LivesCounter = %LivesCounter


func _ready() -> void:
	add_to_group(GROUP)

	Audio.play_music(Audio.MUSIC_GAME)
	
	StaticFX.get_instance().coverage = 0
	SignalBus.player_died.connect(lives_counter_container.show)
	SignalBus.player_restarted_level.connect(load_level)
	load_level()


func add_lives(amount: int) -> void:
	lives += amount


func on_blur() -> void:
	get_tree().paused = true


func on_focus() -> void:
	get_tree().paused = false


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		SceneManager.push_paused_scene()


func load_level() -> void:
	if level:
		level.queue_free()

	lives_counter_container.hide()

	level = LEVEL_SCENE.instantiate()
	add_child(level)

	var palette_shader: PaletteShader = PaletteShader.get_instance()
	palette_shader.brightness = 1
	await Util.timer(0.3)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(palette_shader, "brightness", 0, 3 / 12.0)
	await tween.finished
