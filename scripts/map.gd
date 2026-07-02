class_name GameMap
extends Node2D
## Builds the tile visuals, owns the fixed enemy path and tower occupancy.

const CELL := 64
const GRID_W := 20
const GRID_H := 10

## Fixed path as grid corner points (col, row). Enemies walk segment to segment.
const PATH_POINTS := [
	Vector2i(0, 2), Vector2i(15, 2), Vector2i(15, 5),
	Vector2i(3, 5), Vector2i(3, 8), Vector2i(19, 8),
]

var path_cells := {}          # Dictionary used as a set of Vector2i
var occupied := {}            # Vector2i -> Tower
var blocked := {}             # decorative cells, not buildable
var waypoints: PackedVector2Array = []

## Hand-placed decoration cells (rocks block building, adds placement texture).
const DECO_CELLS := [
	Vector2i(1, 0), Vector2i(5, 0), Vector2i(11, 1), Vector2i(18, 1),
	Vector2i(1, 4), Vector2i(9, 4), Vector2i(17, 6), Vector2i(2, 6),
	Vector2i(7, 9), Vector2i(14, 9),
]

func _ready() -> void:
	_collect_path_cells()
	_build_waypoints()
	_build_tiles()
	_build_decorations()
	_place_base_sprite()

func _collect_path_cells() -> void:
	for i in range(PATH_POINTS.size() - 1):
		var a: Vector2i = PATH_POINTS[i]
		var b: Vector2i = PATH_POINTS[i + 1]
		var step := (b - a).sign()
		var c := a
		path_cells[c] = true
		while c != b:
			c += step
			path_cells[c] = true

func _build_waypoints() -> void:
	waypoints.clear()
	# Start slightly off-screen so enemies walk in.
	var first := cell_center(PATH_POINTS[0])
	waypoints.append(first + Vector2(-CELL, 0))
	for p in PATH_POINTS:
		waypoints.append(cell_center(p))

func _build_tiles() -> void:
	var grass: Texture2D = load("res://assets/sprites/grass.png")
	var grass2: Texture2D = load("res://assets/sprites/grass2.png")
	var path_tex: Texture2D = load("res://assets/sprites/path.png")
	var rng := RandomNumberGenerator.new()
	rng.seed = 1234
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
	rng.seed = 42
	for cell in DECO_CELLS:
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
	s.position = cell_center(PATH_POINTS[PATH_POINTS.size() - 1])
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
	# Keep the base cell clear of towers (it's on the path anyway, but be safe).
	if cell == PATH_POINTS[PATH_POINTS.size() - 1]:
		return false
	return true

func occupy(cell: Vector2i, tower: Node) -> void:
	occupied[cell] = tower

func release(cell: Vector2i) -> void:
	occupied.erase(cell)

func tower_at(cell: Vector2i) -> Node:
	return occupied.get(cell, null)
