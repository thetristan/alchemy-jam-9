class_name FirstFinishedAwait
extends RefCounted
## Helper that accepts multiple CancellableAwaits and finishes when 
## the first await completes, cancelling the rest
##
## Can only be used once 

## Emitted when the first await completes
signal finished(winner: CancellableAwait)

## True when completed
var completed: bool

var _cancellables: Array[CancellableAwait]
var _finished_callables: Dictionary[CancellableAwait, Callable]


func _init(cancellables: Array[CancellableAwait]) -> void:
	_cancellables = cancellables
	for cancellable in _cancellables:
		_finished_callables[cancellable] = _on_finished(cancellable)
		cancellable.finished.connect(_finished_callables[cancellable])
			

func _on_finished(winner: CancellableAwait) -> Callable:
	return func(cancelled: bool):
		if cancelled:
			return

		completed = true

		for cancellable in _cancellables:
			if cancellable != winner:
				cancellable.cancel()

			if cancellable.finished.is_connected(_finished_callables[cancellable]):
				cancellable.finished.disconnect(_finished_callables[cancellable])
				_finished_callables.erase(cancellable)

		finished.emit(winner)
