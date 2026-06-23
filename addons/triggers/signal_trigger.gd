@tool
@icon("res://addons/triggers/icons/trigger-icon-delay.svg")
class_name SignalTrigger
extends Trigger
## Starts waiting for a signal to be fired when triggered before continuing 
## the trigger chain. Will give up after the specified time has passed

## Target node containing the signal to wait for
@export var target_node: Node

## Name of the signal to wait for
@export var signal_name: StringName

## Number of args to unbind if the signal has one or more arguments
@export var unbind_nargs: int

## Max time in seconds to wait for the signal to fire before giving up and cancelling
## Will wait indefinitely when 0 is used
@export var max_wait: float = 10

## When true, will start waiting for the configured signal on ready instead of 
## waiting for this trigger to be triggered first before waiting
@export var start_waiting_on_ready: bool


func _ready() -> void:
	# Wire up children
	super._ready()

	# Report any errors
	var is_valid: bool = valid_config()

	if not Engine.is_editor_hint() and is_valid and start_waiting_on_ready:
		_start_awaiting()


func valid_config() -> bool:
	var valid: bool = true

	if not target_node:
		Log.error(self , valid_config, "no target node assigned")
		valid = false

	if not signal_name:
		Log.error(self , valid_config, "no signal assigned")
		valid = false

	if target_node and not target_node.has_signal(signal_name):
		Log.error(self , valid_config, "target node %s doesn't have signal named %s" % [target_node.get_path(), signal_name])
		valid = false

	if max_wait < 0:
		Log.error(self , valid_config, "max_wait must be greater than or equal to 0")
		valid = false

	return valid


func _start_awaiting() -> void:
	if max_wait > 0:
		Log.info(self , trigger, "setting up await for signal %s:%s; will cancel after %fs" % [target_node.get_path(), signal_name, max_wait])
		var signal_awaiter: CancellableAwait = CancellableAwait.new(target_node.get(signal_name), unbind_nargs)
		var deadline_awaiter: CancellableAwait = CancellableAwait.new(get_tree().create_timer(max_wait, false).timeout)
		var first_finished_awaiter: FirstFinishedAwait = FirstFinishedAwait.new([signal_awaiter, deadline_awaiter])

		first_finished_awaiter.finished.connect(func(winner: CancellableAwait) -> void:
			if winner == signal_awaiter:
				Log.info(self , trigger, "signal %s:%s completed" % [target_node.get_path(), signal_name])
				super.trigger()
			else:
				Log.info(self , trigger, "signal %s:%s failed to complete in %f seconds; skipping trigger" % [target_node.get_path(), signal_name, max_wait]))
	else:
		Log.info(self , trigger, "setting up await for signal %s:%s; no max wait time specified" % [target_node.get_path(), signal_name])
		var signal_awaiter: CancellableAwait = CancellableAwait.new(target_node.get(signal_name), unbind_nargs)
		signal_awaiter.finished.connect(func(cancelled: bool) -> void:
			if not cancelled:
				Log.info(self , trigger, "signal %s:%s completed" % [target_node.get_path(), signal_name])
				super.trigger()
			else:
				Log.info(self , trigger, "signal %s:%s was cancelled; skipping trigger" % [target_node.get_path(), signal_name]))

			
func trigger() -> void:
	if start_waiting_on_ready or not can_trigger():
		return

	_start_awaiting()
