@tool
@icon("res://triggers/icons/trigger-icon-on-off.svg")
class_name PaletteTrigger
extends Trigger

enum Action {ENABLE_FLICKER, DISABLE_FLICKER, SET_BRIGHTNESS}
@export var action: Action = Action.ENABLE_FLICKER
@export var brightness_value: float = 0.0


func _ready() -> void:
	# Wire up children
	super._ready()

	# Report any errors
	valid_config()


func trigger() -> void:
	if not can_trigger():
		return

	var palette: PaletteShader = PaletteShader.get_instance()
	if not palette:
		Log.error(self, trigger, "no palette found")

	match action:
		Action.ENABLE_FLICKER:
			Log.info(self, trigger, "enabling flicker")
			palette.enable_flicker = true
		Action.DISABLE_FLICKER:
			Log.info(self, trigger, "disabling flicker")
			palette.enable_flicker = false
		Action.SET_BRIGHTNESS:
			Log.info(self, trigger, "setting brightness to %s" % brightness_value)
			palette.brightness = brightness_value

	super.trigger()
