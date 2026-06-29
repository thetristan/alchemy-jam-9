class_name Game
extends Node2D

const GROUP: String = "game"

const STARTING_LIVES: int = 1
const MAX_LIVES: int = 99

const MAX_TIME: float = 20 * 60.0

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


var time_left: float:
	set(new_val):
		var clamped: float = clampf(new_val, 0.0, MAX_TIME)
		var seconds_changed: bool = roundi(clamped) != roundi(time_left)
		time_left = clamped

		if seconds_changed:
			SignalBus.seconds_elapsed.emit(roundi(time_left))

		if is_zero_approx(time_left):
			game_over()
			return
	
	
var first_play: bool = true
var clock_started: bool


@onready var lives_counter_container: PanelContainer = %LivesCounterContainer
@onready var lives_counter: LivesCounter = %LivesCounter
@onready var gameplay_hud: MarginContainer = %GameplayHUD
@onready var health_bar: HealthBar = %HealthBar
@onready var time_counter: TimeCounter = %TimeCounter
@onready var dialogue_panel: PanelContainer = %DialoguePanel


func _ready() -> void:
	add_to_group(GROUP)
	Audio.play_music(Audio.MUSIC_GAME)
	StaticFX.get_instance().coverage = 0
	SignalBus.player_health_changed.connect(func(health: int, _max_health: int) -> void:
		if health == 0:
			clock_started = false)
	SignalBus.player_dying.connect(gameplay_hud.hide)
	SignalBus.player_died.connect(lives_counter_container.show)
	SignalBus.player_restarted_level.connect(load_level)

	set_clock()
	await load_level()


func _process(delta: float) -> void:
	if clock_started and time_left > 0:
		time_left -= delta


func add_lives(amount: int) -> void:
	lives += amount


func game_over() -> void:
	gameplay_hud.hide()
	var player: Player = Player.get_instance()
	if not player.dead:
		Player.get_instance().kill()
		await SignalBus.player_died
	SceneManager.replace_with_game_over_scene(floor(time_left))


func set_clock() -> void:
	time_left = MAX_TIME


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

	gameplay_hud.hide()
	lives_counter_container.hide()

	level = LEVEL_SCENE.instantiate()
	add_child(level)
	Player.get_instance().disable()

	var palette_shader: PaletteShader = PaletteShader.get_instance()
	palette_shader.brightness = 1
	await Util.timer(0.3)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(palette_shader, "brightness", 0, 3 / 12.0)
	await tween.finished

	if first_play:
		dialogue_panel.show()
		await dialogue_panel.start()
		dialogue_panel.hide()
		first_play = false

	gameplay_hud.show()
	Player.get_instance().enable()
	clock_started = true
