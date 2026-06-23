class_name NodeSet
extends RefCounted
## Data structure for holding a set of nodes

var _nodes: Dictionary[Node, bool]
var _cleanup_handlers: Dictionary[Node, Callable]

## Emitted when a node is added
signal node_added(node: Node)

## Emitted when a node is removed
signal node_removed(node: Node)

## Emitted when the first node is added to the empty set
signal set_non_emptied

## Emitted when the set is fully emptied
signal set_emptied


func add(node: Node) -> void:
	Log.debug(self , add, _present_node(node))
	if node and node not in _nodes:
		_nodes[node] = true
		_cleanup_handlers[node] = erase.bind(node)
		node.tree_exited.connect(_cleanup_handlers[node])
		node_added.emit(node)

		if _nodes.size() == 1:
			set_non_emptied.emit()


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

	if _nodes.is_empty():
		set_emptied.emit()


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
