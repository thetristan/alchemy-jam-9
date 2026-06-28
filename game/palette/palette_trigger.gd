@tool
@icon("res://triggers/icons/trigger-icon-on-off.svg")
class_name PaletteTrigger
extends Trigger

enum Action {ENABLE_LIGHTS, DISABLE_LIGHTS}
@export var action: Action = Action.ENABLE_LIGHTS


func _ready() -> void:
	# Wire up children
	super._ready()

	# Report any errors
	valid_config()


func trigger() -> void:
	if not can_trigger():
		return

	var palette: PaletteShader = PaletteShader.get_instance(get_tree())
	if not palette:
		Log.error(self , trigger, "no palette found")

	match action:
		Action.ENABLE_LIGHTS:
			Log.info(self , trigger, "lighting zone")
			palette.zone_lit()
		Action.DISABLE_LIGHTS:
			Log.info(self , trigger, "disabling zone")
			palette.zone_unlit()

	super.trigger()
