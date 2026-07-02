class_name DrawOverlay
extends Node2D
## Draws placement ghost and selection ring above the map and actors.

var game: Node

func _draw() -> void:
	if game == null:
		return
	if game.selected_tower != null and is_instance_valid(game.selected_tower):
		var c: Vector2 = game.selected_tower.position
		var r: float = game.selected_tower.stat_range()
		draw_circle(c, r, Color(0.4, 0.8, 1.0, 0.07))
		draw_arc(c, r, 0, TAU, 64, Color(0.4, 0.8, 1.0, 0.5), 2.0)
		draw_rect(Rect2(c - Vector2(32, 32), Vector2(64, 64)), Color(0.4, 0.8, 1.0, 0.6), false, 2.0)
	if game.placing_type == "" or not game.map.in_grid(game._ghost_cell):
		return
	var center: Vector2 = GameMap.cell_center(game._ghost_cell)
	var ok: bool = game.map.is_buildable(game._ghost_cell)
	var d: Dictionary = GameData.TOWERS[game.placing_type]
	var rng: float = d.range * game.type_bonus[game.placing_type].range
	draw_circle(center, rng, Color(1, 1, 1, 0.08))
	draw_arc(center, rng, 0, TAU, 64, Color(1, 1, 1, 0.35), 2.0)
	var col := Color(0.3, 1.0, 0.3, 0.35) if ok else Color(1.0, 0.25, 0.25, 0.35)
	draw_rect(Rect2(center - Vector2(32, 32), Vector2(64, 64)), col)
