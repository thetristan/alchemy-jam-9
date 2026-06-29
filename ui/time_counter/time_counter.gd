class_name TimeCounter
extends HBoxContainer

const COLOR_CREAM: Color = Color(0.9725490, 0.9176471, 0.8117647, 1)
const COLOR_ORANGE: Color = Color(0.7529412, 0.4941176, 0.3254902, 1)

@export var time_left: int:
	set(new_val):
		time_left = new_val
		if is_node_ready():
			_update_label()

@export var orange: bool = false:
	set(new_val):
		orange = new_val
		if is_node_ready():
			_update_color()

@onready var time_left_label: Label = %TimeLeft
@onready var cream_icon: TextureRect = %CreamIcon
@onready var orange_icon: TextureRect = %OrangeIcon


func _ready() -> void:
	SignalBus.seconds_elapsed.connect(func(new_time_left): time_left = new_time_left)
	_update_label()
	_update_color()


func _update_color() -> void:
	time_left_label.label_settings.font_color = COLOR_ORANGE if orange else COLOR_CREAM
	cream_icon.visible = not orange
	orange_icon.visible = orange


func _update_label() -> void:
	var minutes: int = floor(round(time_left) / 60)
	var seconds: int = time_left % 60
	time_left_label.text = "%02d:%02d" % [minutes, seconds]
