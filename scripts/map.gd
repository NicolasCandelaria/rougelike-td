class_name GameMap
extends Node2D
## Builds tile visuals, owns enemy paths and tower occupancy for a selected map.

const CELL := 64
const GRID_W := 20
const GRID_H := 10

var path_cells := {}          # Dictionary used as a set of Vector2i
var occupied := {}            # Vector2i -> Tower
var blocked := {}             # decorative cells, not buildable
var waypoints_list: Array = []  # Array of PackedVector2Array, one per spawn path
var base_cell := Vector2i.ZERO

var _map_data: Dictionary = {}

func setup(map_index: int) -> void:
	_map_data = GameData.map_by_index(map_index)
	for child in get_children():
		child.queue_free()
	path_cells.clear()
	occupied.clear()
	blocked.clear()
	waypoints_list.clear()
	_collect_path_cells()
	_build_waypoints()
	_build_tiles()
	_build_decorations()
	_place_base_sprite()

func _collect_path_cells() -> void:
	for path_def in _map_data.paths:
		var points: Array = path_def.points
		for i in range(points.size() - 1):
			var a: Vector2i = points[i]
			var b: Vector2i = points[i + 1]
			var step := (b - a).sign()
			var c := a
			path_cells[c] = true
			while c != b:
				c += step
				path_cells[c] = true
		base_cell = points[points.size() - 1]

func _build_waypoints() -> void:
	waypoints_list.clear()
	for path_def in _map_data.paths:
		var points: Array = path_def.points
		var offset: Vector2 = path_def.get("spawn_offset", Vector2(-CELL, 0))
		var wps := PackedVector2Array()
		var first := cell_center(points[0])
		wps.append(first + offset)
		for p in points:
			wps.append(cell_center(p))
		waypoints_list.append(wps)

func _build_tiles() -> void:
	var grass: Texture2D = load("res://assets/sprites/grass.png")
	var grass2: Texture2D = load("res://assets/sprites/grass2.png")
	var path_tex: Texture2D = load("res://assets/sprites/path.png")
	var rng := RandomNumberGenerator.new()
	rng.seed = int(_map_data.get("deco_seed", 1234))
	for y in range(GRID_H):
		for x in range(GRID_W):
			var cell := Vector2i(x, y)
			var s := Sprite2D.new()
			if path_cells.has(cell):
				s.texture = path_tex
			else:
				s.texture = grass2 if rng.randf() < 0.18 else grass
			s.position = cell_center(cell)
			add_child(s)

func _build_decorations() -> void:
	var texs := [
		"res://assets/sprites/deco_rock_a.png", "res://assets/sprites/deco_rock_b.png",
		"res://assets/sprites/deco_rock_c.png", "res://assets/sprites/deco_bush.png",
		"res://assets/sprites/deco_tree.png",
	]
	var rng := RandomNumberGenerator.new()
	rng.seed = int(_map_data.get("deco_seed", 42)) + 17
	for cell in _map_data.get("deco_cells", []):
		if path_cells.has(cell):
			continue
		blocked[cell] = true
		var s := Sprite2D.new()
		s.texture = load(texs[rng.randi_range(0, texs.size() - 1)])
		s.position = cell_center(cell)
		s.rotation = rng.randf_range(-0.4, 0.4)
		s.z_index = 2
		add_child(s)

func _place_base_sprite() -> void:
	var s := Sprite2D.new()
	s.texture = load("res://assets/sprites/base_hq.png")
	s.position = cell_center(base_cell)
	s.z_index = 5
	add_child(s)

static func cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * CELL + CELL / 2.0, cell.y * CELL + CELL / 2.0)

static func pos_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(floori(pos.x / CELL), floori(pos.y / CELL))

func in_grid(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < GRID_W and cell.y >= 0 and cell.y < GRID_H

func is_buildable(cell: Vector2i) -> bool:
	if not in_grid(cell):
		return false
	if path_cells.has(cell):
		return false
	if occupied.has(cell):
		return false
	if blocked.has(cell):
		return false
	if cell == base_cell:
		return false
	return true

func occupy(cell: Vector2i, tower: Node) -> void:
	occupied[cell] = tower

func release(cell: Vector2i) -> void:
	occupied.erase(cell)

func tower_at(cell: Vector2i) -> Node:
	return occupied.get(cell, null)

func waypoints_for_spawn(spawn_idx: int) -> PackedVector2Array:
	if waypoints_list.is_empty():
		return PackedVector2Array()
	return waypoints_list[clampi(spawn_idx, 0, waypoints_list.size() - 1)]

## Backward-compatible single-path accessor.
func get_waypoints() -> PackedVector2Array:
	return waypoints_for_spawn(0)
