class_name DialoguePanel
extends PanelContainer

signal finished

const SENDER_NAME_BLINK_INTERVAL: float = 1.0 / 3.0

@onready var profile_sprite: AnimatedSprite2D = %ProfileSprite
@onready var sender_name: Label = %SenderName
@onready var message: Label = %Message
@onready var time_counter: TimeCounter = %TimeCounter

var _message_tween: Tween
var _blink_tween: Tween
var _cancel_dialogue: CancellableAwait

func _ready() -> void:
	message.visible_characters = 0
	time_counter.hide()
	profile_sprite.play()

	_blink_tween = create_tween().set_loops()
	_blink_tween.tween_callback(func() -> void: sender_name.modulate.a = 1.0 - sender_name.modulate.a)
	_blink_tween.tween_interval(SENDER_NAME_BLINK_INTERVAL)


func start() -> void:
	var length: int = message.text.length()
	var duration: float = 0.05 * length
	_message_tween = create_tween()
	_message_tween.tween_property(message, "visible_characters", length, duration)
	_cancel_dialogue = CancellableAwait.new(_message_tween.finished)
	if await _cancel_dialogue.finished:
		_message_tween.kill()
		message.visible_characters = length

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
