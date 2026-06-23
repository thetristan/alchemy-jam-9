class_name LogConfig
extends Resource
## Configuration settings for logging

@export_category("Logging")

enum LogLevel {NONE, ERROR, WARNING, INFO, DEBUG}
@export var log_level: LogLevel = LogLevel.WARNING
@export var log_date_time: bool = true
@export var log_process_frame: bool = false
@export var log_physics_frame: bool = false
@export var stacktrace_on_warn_error: bool = true
