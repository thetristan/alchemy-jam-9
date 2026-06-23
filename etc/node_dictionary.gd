class_name NodeDictionary
extends RefCounted
## Data structure for holding a dictionary of nodes mapped to values

var _nodes: Dictionary[Node, Variant]
var _cleanup_handlers: Dictionary[Node, Callable]

## Emitted when a node is added
signal node_added(node: Node)

## Emitted when a node is removed
signal node_removed(node: Node)


func set_value(node: Node, value: Variant) -> void:
	Log.debug(self , set_value, _present_node(node))
	if node and node not in _nodes:
		_cleanup_handlers[node] = erase.bind(node)
		node.tree_exited.connect(_cleanup_handlers[node])
		node_added.emit(node)

	if node:
		_nodes[node] = value


func get_value(node: Node) -> Variant:
	return _nodes.get(node)


func has(node: Node) -> bool:
	return node in _nodes


func get_nodes() -> Array[Node]:
	return _nodes.keys()


func erase(node: Node) -> void:
	Log.debug(self , erase, _present_node(node))
	if node in _cleanup_handlers:
		node.tree_exited.disconnect(_cleanup_handlers[node])
		_cleanup_handlers.erase(node)

	_nodes.erase(node)
	node_removed.emit(node)


func clear() -> void:
	for node in _nodes.keys():
		erase(node)


func is_empty() -> bool:
	return _nodes.is_empty()


func _present_node(node: Node):
	if node.is_inside_tree():
		return node.get_path()
	else:
		return str(node)
