class_name GameWon
extends CanvasLayer

var metrics: Metrics

@onready var quit_btn: Button = %MainMenu

@onready var time_taken_label: Label = %TimeTaken
@onready var damage_taken_label: Label = %DamageTaken
@onready var number_deaths_label: Label = %NumberDeaths
@onready var rails_rode_label: Label = %RailsRode
@onready var traps_snapped_label: Label = %TrapsSnapped
@onready var metrics_container: Control = %MetricsContainer

func on_start_game() -> void:
	_disable_button()
	SceneManager.replace_with_game_scene()


func on_quit_game() -> void:
	_disable_button()
	SceneManager.replace_with_title_scene()


func _ready() -> void:
	get_tree().paused = false
	Audio.play_music(Audio.MUSIC_GAME_WON)
	quit_btn.pressed.connect(on_quit_game)
	quit_btn.pressed.connect(func() -> void: Audio.play_sfx(Audio.SFX_UI_ACCEPT))
	_update_metrics()

	metrics_container.offset_transform_enabled = true
	metrics_container.offset_transform_position.y -= 180
	await Util.timer(0.5)
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(metrics_container, "offset_transform_position", Vector2.ZERO, 0.5)
	await tween.finished
	

	_enable_button()


func _update_metrics() -> void:
	if not metrics:
		return

	@warning_ignore("integer_division")
	var minutes: int = metrics.time_taken / 60
	var seconds: int = metrics.time_taken % 60
	time_taken_label.text = "%02d:%02d" % [minutes, seconds]
	damage_taken_label.text = str(metrics.hits_taken)
	number_deaths_label.text = str(metrics.num_deaths)
	rails_rode_label.text = str(metrics.rails_rode)
	traps_snapped_label.text = str(metrics.num_traps)


func on_blur() -> void:
	_disable_button()
	

func on_focus() -> void:
	_enable_button()


func _enable_button() -> void:
	quit_btn.disabled = false
	quit_btn.focus_mode = Control.FOCUS_ALL
	quit_btn.grab_focus()
	

func _disable_button() -> void:
	quit_btn.disabled = true
	quit_btn.focus_mode = Control.FOCUS_NONE
