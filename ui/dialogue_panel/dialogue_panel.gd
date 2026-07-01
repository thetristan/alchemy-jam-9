class_name DialoguePanel
extends PanelContainer

signal finished

const SENDER_NAME_BLINK_INTERVAL: float = 1.0 / 3.0

const STATIC_COVERAGE_MIN: float = 0.4
const STATIC_COVERAGE_MAX: float = 0.8
const STATIC_COVERAGE_RAMP_DURATION: float = 1.0

const PALETTE_BRIGHTNESS_MIN: float = -0.3
const PALETTE_BRIGHTNESS_MAX: float = 0.7

@onready var profile_sprite: AnimatedSprite2D = %ProfileSprite
@onready var sender_name: Label = %SenderName
@onready var message: Label = %Message
@onready var time_counter: TimeCounter = %TimeCounter
@onready var static_sprite: StaticFX = %StaticSprite
@onready var palette_shader: PaletteShader = %MiniPaletteShader

@onready var dialogue_loop_sfx: AudioStreamPlayer = %DialogueLoopSFX

var _message_tween: Tween
var _blink_tween: Tween
var _static_tween: Tween
var _cancel_dialogue: CancellableAwait

func _ready() -> void:
	message.visible_characters = 0
	time_counter.hide()
	profile_sprite.play()

	static_sprite.coverage = STATIC_COVERAGE_MIN
	palette_shader.brightness = PALETTE_BRIGHTNESS_MIN
	_static_tween = create_tween().set_loops()
	_static_tween.tween_property(static_sprite, "coverage", STATIC_COVERAGE_MAX, STATIC_COVERAGE_RAMP_DURATION)
	_static_tween.parallel().tween_property(palette_shader, "brightness", PALETTE_BRIGHTNESS_MAX, STATIC_COVERAGE_RAMP_DURATION)
	_static_tween.tween_property(static_sprite, "coverage", STATIC_COVERAGE_MIN, STATIC_COVERAGE_RAMP_DURATION)
	_static_tween.parallel().tween_property(palette_shader, "brightness", PALETTE_BRIGHTNESS_MIN, STATIC_COVERAGE_RAMP_DURATION)

	_blink_tween = create_tween().set_loops()
	_blink_tween.tween_callback(func() -> void: sender_name.modulate.a = 1.0 - sender_name.modulate.a)
	_blink_tween.tween_interval(SENDER_NAME_BLINK_INTERVAL)


func start() -> void:
	offset_transform_enabled = true
	offset_transform_position.y -= 180
	await Util.timer(0.5)
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "offset_transform_position", Vector2.ZERO, 0.5)
	await tween.finished
	
	var length: int = message.text.length()
	var duration: float = 0.05 * length
	_message_tween = create_tween()
	_message_tween.tween_property(message, "visible_characters", length, duration)
	_cancel_dialogue = CancellableAwait.new(_message_tween.finished)
	dialogue_loop_sfx.play()
	if await _cancel_dialogue.finished:
		_message_tween.kill()
		message.visible_characters = length

	dialogue_loop_sfx.stop()
	if _blink_tween:
		_blink_tween.kill()
	sender_name.modulate.a = 1.0

	time_counter.show()
	_cancel_dialogue = null
	await finished
	

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("jump"):
		return

	if _cancel_dialogue:
		_cancel_dialogue.cancel()
	else:
		finished.emit()
