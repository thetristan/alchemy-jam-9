class_name Log
extends RefCounted
## Static Logging Helper
## 
## Inspired by https://github.com/TheDuriel/DurielUtilities/tree/main/Logger


const APP_CONFIG: LogConfig = preload("res://log_config.tres")
const MAX_LOG_LEVEL: LogConfig.LogLevel = LogConfig.LogLevel.DEBUG

static var _runtime_level: int = -1


static func get_log_level() -> int:
	if _runtime_level >= 0:
		return _runtime_level
	return APP_CONFIG.log_level if APP_CONFIG else LogConfig.LogLevel.WARNING


static func set_log_level(level: LogConfig.LogLevel) -> void:
	_runtime_level = level


static func cycle_log_level() -> void:
	_runtime_level = (_runtime_level + 1) % (MAX_LOG_LEVEL + 1)


## Debugs are gray
static func debug(emitter: Object, function: Callable, message = "") -> void:
	if not get_log_level() >= LogConfig.LogLevel.DEBUG:
		return

	var msg: String = _get_message("DEBUG", emitter, function, str(message))
	if OS.has_feature("web"):
		print(msg)
	else:
		msg = "[color=gray]%s[/color]" % msg
		print_rich(msg)


## Infos are white.
static func info(emitter: Object, function: Callable, message = "") -> void:
	if not get_log_level() >= LogConfig.LogLevel.INFO:
		return
	
	var msg: String = _get_message("INFO", emitter, function, str(message))
	if OS.has_feature("web"):
		print(msg)
	else:
		msg = "[color=white]%s[/color]" % msg
		print_rich(msg)


## Warnings are yellow. A warning indicates execution continued despite a problem.
static func warn(emitter: Object, function: Callable, message = "") -> void:
	if not get_log_level() >= LogConfig.LogLevel.WARNING:
		return
	
	var msg: String = _get_message("WARN", emitter, function, str(message))
	if OS.has_feature("web"):
		print(msg)
	else:
		msg = "[color=yellow]%s[/color]" % msg
		print_rich(msg)

	if APP_CONFIG and APP_CONFIG.stacktrace_on_warn_error:
		print_stack()


## Errors are red. An error indicates that execution was stopped.
static func error(emitter: Object, function: Callable, message = "") -> void:
	if not get_log_level() >= LogConfig.LogLevel.ERROR:
		return
	
	var msg: String = _get_message("ERROR", emitter, function, str(message))
	if OS.has_feature("web"):
		print(msg)
	else:
		msg = "[color=red]%s[/color]" % msg
		print_rich(msg)
	
	if APP_CONFIG and APP_CONFIG.stacktrace_on_warn_error:
		print_stack()


static func _get_message(prefix: String, emitter: Object, function: Callable, message: String = "") -> String:
	var obj_name: String = emitter.get_class()
	if emitter.get_script():
		var script: Script = emitter.get_script()
		if script.get_global_name():
			obj_name = script.get_global_name()
		elif script:
			obj_name = script.get_path().get_file()

	var func_name: String = function.get_method()

	var metadata: Array[String]
	var result: Array[String]
	if APP_CONFIG and APP_CONFIG.log_date_time:
		metadata.append(Time.get_datetime_string_from_system())

		
	if APP_CONFIG and APP_CONFIG.log_process_frame:
		metadata.append("process=%d" % Engine.get_process_frames())

	if APP_CONFIG and APP_CONFIG.log_physics_frame:
		metadata.append("physics=%d" % Engine.get_physics_frames())

	if metadata:
		result.append("[%s]" % " ".join(metadata))

	result.append("[%s]" % prefix)

	var emitter_id: String
	if emitter is Node:
		emitter_id = emitter.get_path()
	else:
		emitter_id = "%x" % emitter.get_instance_id()
		
	if obj_name:
		result.append("%s::%s" % [obj_name, func_name])
	else:
		result.append(func_name)

	result.append("(%s)" % emitter_id)

	if message:
		result.append("-")
		result.append(message)
	
	return " ".join(result)


static func get_object_file_name(object: Object) -> String:
	var script: Script = object.get_script()
	
	if script:
		return script.resource_path.get_file()
	
	return object.get_class()
