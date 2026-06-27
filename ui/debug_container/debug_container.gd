class_name DebugContainer
extends MarginContainer


const GROUP: String = "debug_container"

enum UpdateMode {PROCESS, PHYSICS_PROCESS}

@export var watch_expressions: Array[DebugWatch]
@export var update_mode: UpdateMode = UpdateMode.PROCESS

@onready var watch_expressions_container: GridContainer = %WatchExpressions

var node_labels: Dictionary[String, Label] = {}
var key_labels: Dictionary[String, Label] = {}
var value_labels: Dictionary[String, Label] = {}
var watched_nodes: Dictionary[String, Node] = {}
var parsed_expressions: Dictionary[String, Expression] = {}
var node_keys: Dictionary[Node, Array] = {}


static func get_instance(tree: SceneTree) -> DebugContainer:
	return tree.get_first_node_in_group(DebugContainer.GROUP) as DebugContainer


func _ready() -> void:
	visible = false
	add_to_group(GROUP)
	for watch: DebugWatch in watch_expressions:
		if not watch.enabled:
			continue
		var node: Node = get_node_or_null(watch.node_path)
		if not node:
			Log.warn(self, _ready, "node not found at '%s'" % watch.node_path)
			continue
		var alias: String = watch.node_alias if watch.node_alias else str(watch.node_path.slice(-1))
		_add_watch(node, watch.expressions, alias)


static func _key(node_name: Variant, expr: String) -> String:
	return str(node_name) + "_" + expr


func _add_watch_row(key: String, node_text: String, expr_text: String) -> void:
	node_labels[key] = Label.new()
	node_labels[key].text = node_text
	watch_expressions_container.add_child(node_labels[key])

	key_labels[key] = Label.new()
	key_labels[key].text = expr_text
	watch_expressions_container.add_child(key_labels[key])

	value_labels[key] = Label.new()
	watch_expressions_container.add_child(value_labels[key])


func _remove_watch_row(key: String) -> void:
	node_labels[key].queue_free()
	node_labels.erase(key)
	key_labels[key].queue_free()
	key_labels.erase(key)
	value_labels[key].queue_free()
	value_labels.erase(key)
	watched_nodes.erase(key)
	parsed_expressions.erase(key)


static func add_watch(tree: SceneTree, node: Node, expressions: Array[String], alias: String = "") -> void:
	var instance: DebugContainer = get_instance(tree)
	if instance:
		instance._add_watch(node, expressions, alias)


static func remove_watch(tree: SceneTree, node: Node, expressions: Array[String] = []) -> void:
	var instance: DebugContainer = get_instance(tree)
	if instance:
		instance._remove_watch(node, expressions)


func _add_watch(node: Node, expressions: Array[String], alias: String = "") -> void:
	var node_text: String = alias if not alias.is_empty() else str(node.name)
	for expr: String in expressions:
		var key: String = _key(node.name, expr)
		if watched_nodes.has(key):
			continue

		var expression: Expression = Expression.new()
		var error: Error = expression.parse(expr)
		if error != OK:
			Log.warn(self, _add_watch, "failed to parse expression '%s': %s" % [expr, error_string(error)])
			continue

		watched_nodes[key] = node
		parsed_expressions[key] = expression

		if not node_keys.has(node):
			node_keys[node] = []
			node.tree_exiting.connect(_on_node_tree_exiting.bind(node))
		node_keys[node].append(key)

		_add_watch_row(key, node_text, expr)


func _remove_watch(node: Node, expressions: Array[String] = []) -> void:
	if not node_keys.has(node):
		return

	var keys_to_remove: Array[String] = []
	if expressions.is_empty():
		keys_to_remove.assign(node_keys[node])
	else:
		for expr: String in expressions:
			var key: String = _key(node.name, expr)
			if watched_nodes.has(key):
				keys_to_remove.append(key)

	for key: String in keys_to_remove:
		_remove_watch_row(key)
		node_keys[node].erase(key)

	if node_keys[node].is_empty():
		node_keys.erase(node)
		if node.tree_exiting.is_connected(_on_node_tree_exiting):
			node.tree_exiting.disconnect(_on_node_tree_exiting)


func _on_node_tree_exiting(node: Node) -> void:
	_remove_watch(node)


func _unhandled_input(event: InputEvent) -> void:
	if GameOptions.debug_mode and event.is_action_pressed("debug_panel_toggle"):
		visible = not visible


func _process(delta: float) -> void:
	if update_mode == UpdateMode.PROCESS:
		_update_watches(delta)


func _physics_process(delta: float) -> void:
	if update_mode == UpdateMode.PHYSICS_PROCESS:
		_update_watches(delta)


func _update_watches(_delta: float) -> void:
	for key: String in watched_nodes:
		var node: Node = watched_nodes[key]
		if not is_instance_valid(node):
			continue
		var result: Variant = parsed_expressions[key].execute([], node)
		if parsed_expressions[key].has_execute_failed():
			value_labels[key].text = "<error>"
		else:
			value_labels[key].text = str(result)
