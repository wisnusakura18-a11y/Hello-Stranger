extends Node2D

func _ready() -> void:
	var tile_map: TileMap = get_node_or_null("TileMap") as TileMap
	if tile_map != null and tile_map.tile_set != null:
		var layers: int = tile_map.tile_set.get_physics_layers_count()
		for i in layers:
			tile_map.tile_set.set_physics_layer_collision_layer(i, 0)
			tile_map.tile_set.set_physics_layer_collision_mask(i, 0)

	var legacy: StaticBody2D = get_node_or_null("colisitions") as StaticBody2D
	if legacy != null:
		legacy.collision_layer = 0
		legacy.collision_mask = 0

	call_deferred("_build_walk_boundary")

func _build_walk_boundary() -> void:
	var tile_map: TileMap = get_node_or_null("TileMap") as TileMap
	if tile_map == null or tile_map.tile_set == null:
		return
	var old: Node = get_node_or_null("WalkBoundary")
	if old != null and is_instance_valid(old):
		old.queue_free()

	var rect: Rect2i = tile_map.get_used_rect()
	var tile_size: Vector2i = tile_map.tile_set.tile_size
	if rect.size.x <= 0 or rect.size.y <= 0:
		return

	var left: float = float(rect.position.x * tile_size.x) + tile_map.position.x
	var top: float = float(rect.position.y * tile_size.y) + tile_map.position.y
	var right: float = float((rect.position.x + rect.size.x) * tile_size.x) + tile_map.position.x
	var bottom: float = float((rect.position.y + rect.size.y) * tile_size.y) + tile_map.position.y
	var width: float = right - left
	var height: float = bottom - top
	var thickness: float = 16.0

	var boundary: StaticBody2D = StaticBody2D.new()
	boundary.name = "WalkBoundary"
	boundary.collision_layer = 1
	boundary.collision_mask = 1
	add_child(boundary)

	_add_wall(boundary, Vector2(left - thickness * 0.5, top + height * 0.5), Vector2(thickness, height + thickness * 2.0))
	_add_wall(boundary, Vector2(right + thickness * 0.5, top + height * 0.5), Vector2(thickness, height + thickness * 2.0))
	_add_wall(boundary, Vector2(left + width * 0.5, top - thickness * 0.5), Vector2(width + thickness * 2.0, thickness))
	_add_wall(boundary, Vector2(left + width * 0.5, bottom + thickness * 0.5), Vector2(width + thickness * 2.0, thickness))

func _add_wall(parent: StaticBody2D, wall_position: Vector2, wall_size: Vector2) -> void:
	var shape_node: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = wall_size
	shape_node.position = wall_position
	shape_node.shape = shape
	parent.add_child(shape_node)
