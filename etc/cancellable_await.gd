class_name CancellableAwait
extends RefCounted
## Helper that enables cancelling an awaited signal
##
## Can only be used once 

## Emitted when the await is cancelled
signal cancelled

## Emitted when the awaited signal emits or the await is cancelled
signal finished(cancelled: bool)

## True when completed
var completed: bool

var _awaitable_signal: Signal
var _finished_callable: Callable


func _init(awaitable_signal_: Signal, nargs: int = 0) -> void:
	var _on_finished = func() -> void:
		completed = true
		finished.emit(false)
	
	if nargs:
		_finished_callable = _on_finished.unbind(nargs)
	else:
		_finished_callable = _on_finished

	_awaitable_signal = awaitable_signal_
	_awaitable_signal.connect(_finished_callable)


## Cancels the awaited action
func cancel() -> void:
	if completed:
		Log.error(self , cancel, "Can't cancel an already completed CancellableAwait")
		return

	if _awaitable_signal.is_connected(_finished_callable):
		_awaitable_signal.disconnect(_finished_callable)

	Log.debug(self , _init, "%s cancelled" % _awaitable_signal)
	completed = true

	cancelled.emit()
	finished.emit(true)


func _to_string() -> String:
	return "CancellableAwait{signal=%s}" % str(_awaitable_signal)
