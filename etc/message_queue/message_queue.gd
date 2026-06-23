class_name MessageQueue
extends RefCounted

signal shown(msg: String, color: Color)

static var default_color: Color = Color.WHITE

var _default_msg: MessageData = MessageData.new()
var _message_visible: bool
var _current_msg: MessageData
var _queue: Array[MessageData]
var _last_frame_queue_size: int
var _next_id: int
var _keyed_messages: Dictionary[StringName, int]

const EMPTY_MESSAGE: String = ""


class MessageData:
	var id: int
	var key: StringName
	var msg: String
	var color: Color
	var priority: int
	var duration: float
	var interval: float
	var next_interval: float


func _sort_queue() -> void:
	_queue.sort_custom(func(a: MessageData, b: MessageData) -> bool:
		if a.priority == b.priority:
			return a.id > b.id
		return a.priority > b.priority)


func _show_current(msg: MessageData) -> void:
	shown.emit(msg.msg, msg.color)


func _show_default() -> void:
	shown.emit(_default_msg.msg, _default_msg.color)


func _clear_shown() -> void:
	shown.emit(EMPTY_MESSAGE, default_color)


func set_default_message(msg: String, color: Color = default_color) -> void:
	_default_msg.msg = msg
	_default_msg.color = color
	if _queue.is_empty():
		_show_default()


func enqueue_keyed_message(key: StringName, msg: String, color: Color = default_color, priority: int = 1, duration: float = 3, interval: float = 0) -> void:
	if key in _keyed_messages:
		var idx: int = _queue.find_custom(func(msg_data: MessageData) -> bool:
			return _keyed_messages[key] == msg_data.id)

		if idx >= 0 and idx < _queue.size():
			# Message already exists in the queue for this key so update it instead of inserting new
			var msg_data: MessageData = _queue[idx]
			msg_data.msg = msg
			msg_data.key = key
			msg_data.color = color
			msg_data.priority = priority
			msg_data.duration = duration
			msg_data.interval = interval
			msg_data.next_interval = interval
			_sort_queue()
			_show_current(_queue[0])
			return

	var this_id: int = _next_id
	enqueue_message(msg, color, priority, duration, interval)
	_keyed_messages[key] = this_id


func enqueue_message(msg: String, color: Color = default_color, priority: int = 1, duration: float = 3, interval: float = 0) -> void:
	# Avoid double enqueue if we're showing the same thing and just extend the message
	if _current_msg and _current_msg.msg == msg:
		_current_msg.duration += duration
		return

	var data: MessageData = MessageData.new()
	data.id = _next_id
	_next_id += 1
	data.msg = msg
	data.color = color
	data.priority = priority
	data.duration = duration
	data.interval = interval
	data.next_interval = interval

	_queue.append(data)
	_sort_queue()


func clear() -> void:
	_default_msg.msg = ""
	_queue.clear()
	_show_default()


func handle_queue(delta: float) -> void:
	if _queue.is_empty():
		if _last_frame_queue_size > 0:
			_show_default()
	else:
		var msg: MessageData = _queue[0]
		if _current_msg != msg:
			_show_current(msg)
			_current_msg = msg
			_message_visible = true

		msg.duration -= delta

		var interval_boundary: bool = msg.interval <= 0.0
		if msg.interval > 0.0:
			msg.interval = msg.interval - delta
			if msg.interval <= 0:
				interval_boundary = true
				if !_message_visible:
					_show_current(msg)
					msg.interval = msg.next_interval
				else:
					_clear_shown()
					msg.interval = msg.next_interval / 2

				_message_visible = !_message_visible

		if msg.duration <= 0 and interval_boundary:
			_show_default()
			_queue.pop_front()
			if msg.key and msg.key in _keyed_messages:
				_keyed_messages.erase(msg.key)
			_current_msg = null

	_last_frame_queue_size = _queue.size()
