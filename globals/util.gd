extends Node

@export var auto_screenshot_interval: float = 1.0
@export var auto_screenshot_enabled: bool = false

var _auto_screenshot_elapsed: float = 0.0


func timer(delay: float, process_always: bool = false) -> Signal:
	return get_tree().create_timer(delay, process_always).timeout


func _process(delta: float) -> void:
	# if not auto_screenshot_enabled:
		# return
	# _auto_screenshot_elapsed += delta
	# if _auto_screenshot_elapsed >= auto_screenshot_interval:
	# _auto_screenshot_elapsed = 0.0
	take_screenshot()


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("take_screenshot"):
		take_screenshot()


func take_screenshot() -> void:
	if not OS.has_feature("web"):
		var image: Image = get_viewport().get_texture().get_image()
		var desktop_path: String = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
		var timestamp: String = Time.get_datetime_string_from_system()
		var game_name: String = String(ProjectSettings.get_setting("application/config/name", "")).to_snake_case()
		var filename: String = game_name + "_screenshot_" + timestamp.replace(": ", "_") + ".png"
		var full_path: String = desktop_path + "/" + filename

		var err: int = image.save_png(full_path)
		if err != OK:
			Log.error(self, take_screenshot, "Error saving screenshot: %s" % err)
		else:
			Log.info(self, take_screenshot, "Screenshot saved to: %s" % full_path)
	else:
		Log.info(self, take_screenshot, "Screenshots not supported on web")
