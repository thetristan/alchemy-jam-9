class_name Game
extends Node2D

const GROUP: String = "game"

const STARTING_LIVES: int = 5
const MAX_LIVES: int = 99

const MAX_TIME: float = 20 * 60.0

static func get_instance() -> Game:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if not tree:
		return null

	return tree.get_first_node_in_group(GROUP) as Game


const LEVEL_SCENE_PATH: String = "res://game/levels/level_1.tscn"
var level: Level

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
var checkpoint_reached: StringName
var clock_started: bool
var _pickup_count: int = 0

static var metrics: Metrics


@onready var lives_counter_container: PanelContainer = %LivesCounterContainer
@onready var lives_counter: LivesCounter = %LivesCounter
@onready var lives_counter_pickup: LivesCounter = %LivesCounterPickup
@onready var gameplay_hud: MarginContainer = %GameplayHUD
@onready var health_bar: HealthBar = %HealthBar
@onready var time_counter: TimeCounter = %TimeCounter
@onready var dialogue_panel: PanelContainer = %DialoguePanel
@onready var palette_shader: PaletteShader = %PaletteShader


func _ready() -> void:
	add_to_group(GROUP)
	metrics = Metrics.new()
	Audio.play_music(Audio.MUSIC_GAME)
	StaticFX.get_instance().coverage = 0
	SignalBus.player_health_changed.connect(func(health: int, _max_health: int) -> void:
		if health == 0:
			clock_started = false)
	SignalBus.player_dying.connect(gameplay_hud.hide)
	SignalBus.player_died.connect(lives_counter_container.show)
	SignalBus.player_restarted_level.connect(load_level)
	SignalBus.player_checkpoint_reached.connect(func(id: StringName) -> void: checkpoint_reached = id)

	SignalBus.player_dying.connect(func() -> void: metrics.num_deaths += 1)
	SignalBus.player_hit.connect(func() -> void: metrics.hits_taken += 1)
	SignalBus.player_rail_attached.connect(func() -> void: metrics.rails_rode += 1)
	SignalBus.trap_snapped.connect(func() -> void: metrics.num_traps += 1)

	set_clock()
	await load_level()


func _process(delta: float) -> void:
	if clock_started and time_left > 0:
		time_left -= delta


func add_lives(amount: int) -> void:
	_pickup_count += 1
	lives_counter_pickup.show()

	await Util.timer(1.0)
	lives += amount

	await Util.timer(2.0)
	_pickup_count -= 1
	if _pickup_count == 0:
		lives_counter_pickup.hide()


func game_over() -> void:
	gameplay_hud.hide()
	var player: Player = Player.get_instance()
	if not player.dead:
		Player.get_instance().kill()
		await SignalBus.player_died
	SceneManager.replace_with_game_over_scene()


func game_won() -> void:
	var player: Player = Player.get_instance()
	player.disable()

	await palette_shader.fade_in(4 / 12.0, 1)

	metrics.time_taken = roundi(MAX_TIME - time_left)
	SceneManager.replace_with_game_won_scene(metrics)


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

	level = (load(LEVEL_SCENE_PATH) as PackedScene).instantiate() as Level
	add_child(level)
	level.player.hide()
	level.player.disable()

	if checkpoint_reached:
		level.move_player_to_checkpoint(checkpoint_reached)

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
	level.player.spawn_in()
	clock_started = true
