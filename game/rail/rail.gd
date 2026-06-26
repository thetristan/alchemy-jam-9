class_name Rail
extends Area2D

const GROUP: String = "rail"

static func get_all_instances(tree: SceneTree) -> Array[Rail]:
	var result: Array[Rail]
	for node in tree.get_nodes_in_group(Rail.GROUP):
		result.append(node as Rail)
	return result


@export var open_on_left: bool = true
@export var open_on_right: bool = true


var path: Path2D


func _ready() -> void:
	add_to_group(GROUP)

	# Setup colliders
	for child: Node in get_children():
		path = child as Path2D
		if not path:
			continue

		# Get the points
		var points: PackedVector2Array = path.curve.get_baked_points()
		if points.size() < 2:
			return

		# Invert the path if needed
		if points[0].x > points[-1].x:
			var reversed: Curve2D = Curve2D.new()
			for idx: int in range(path.curve.point_count - 1, -1, -1):
				reversed.add_point(
					path.curve.get_point_position(idx),
					path.curve.get_point_out(idx),
					path.curve.get_point_in(idx)
				)
			path.curve = reversed
			points = path.curve.get_baked_points()
		
		# Setup our collider
		for idx: int in range(1, points.size()):
			var segment: SegmentShape2D = SegmentShape2D.new()
			segment.a = points[idx - 1]
			segment.b = points[idx]
			var shape: CollisionShape2D = CollisionShape2D.new()
			shape.shape = segment
			add_child(shape)

		break
