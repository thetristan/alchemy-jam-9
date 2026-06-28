class_name LivesCounter
extends HBoxContainer

const SHAKE_COUNT: int = 4
const SHAKE_OFFSET: int = 2
const SHAKE_DURATION: float = 0.2

var _shake_tween: Tween

@onready var lives_changed_sfx: AudioStreamPlayer = %LivesChangedSFX
@onready var extra_lives: Label = %ExtraLives

func _ready() -> void:
	var game: Game = Game.get_instance()
	if game:
		extra_lives.text = str(game.lives)

	SignalBus.lives_changed.connect(func(val):
		lives_changed_sfx.play()
		shake()
		extra_lives.text = str(val))


func shake() -> void:
	offset_transform_enabled = true
	if _shake_tween:
		_shake_tween.kill()

	_shake_tween = create_tween()
	_shake_tween.set_trans(Tween.TRANS_SINE)
	var duration: float = SHAKE_DURATION / SHAKE_COUNT
	var direction: int = 1
	for _unused: int in range(SHAKE_COUNT - 1):
		direction *= -1
		_shake_tween.tween_property(self, "offset_transform_position", Vector2(direction * SHAKE_OFFSET, 0), duration)

	_shake_tween.tween_property(self, "offset_transform_position", Vector2.ZERO, duration)
