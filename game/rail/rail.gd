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
@export var enabled: bool = true


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

		# Invert the path if needed. Compare in global space so the left-to-right
		# orientation holds regardless of any transform on the Path2D.
		if path.to_global(points[0]).x > path.to_global(points[-1]).x:
			var reversed: Curve2D = Curve2D.new()
			for idx: int in range(path.curve.point_count - 1, -1, -1):
				reversed.add_point(
					path.curve.get_point_position(idx),
					path.curve.get_point_out(idx),
					path.curve.get_point_in(idx)
				)
			path.curve = reversed
			points = path.curve.get_baked_points()
		
		# Setup our collider. The baked points are in the Path2D's local space, so
		# translate them through global space and back into this Rail's space. That
		# keeps the segments correct regardless of any offset/transform on the Path2D.
		for idx: int in range(1, points.size()):
			var segment: SegmentShape2D = SegmentShape2D.new()
			segment.a = to_local(path.to_global(points[idx - 1]))
			segment.b = to_local(path.to_global(points[idx]))
			var shape: CollisionShape2D = CollisionShape2D.new()
			shape.shape = segment
			add_child(shape)

		break
