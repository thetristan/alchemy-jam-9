@tool
@icon("res://addons/triggers/icons/trigger-icon.svg")
class_name CameraTraumaTrigger
extends Trigger

@export_range(0.0, 10.0) var trauma: float = 0.5


func trigger() -> void:
	if not can_trigger():
		return

	var camera: BleazyCam = BleazyCam.get_instance()
	if camera:
		camera.add_trauma(trauma)
	else:
		Log.error(self, trigger, "No camera instance found")

	super.trigger()
