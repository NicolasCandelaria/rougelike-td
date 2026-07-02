class_name Tower
extends Node2D

var type_id := ""
var cell := Vector2i.ZERO
var game: Node                 # game.gd root, provides multipliers and containers
var cooldown := 0.0
var _gun: Sprite2D
var _rot_offset := 0.0

func setup(id: String, game_ref: Node) -> void:
	type_id = id
	game = game_ref
	var d: Dictionary = GameData.TOWERS[id]
	_rot_offset = d.gun_rot_offset

	var base := Sprite2D.new()
	base.texture = load(d.base_tex)
	add_child(base)

	_gun = Sprite2D.new()
	_gun.texture = load(d.gun_tex)
	_gun.modulate = d.gun_tint
	_gun.z_index = 1
	add_child(_gun)
	z_index = 8

func stat_damage() -> float:
	var d: Dictionary = GameData.TOWERS[type_id]
	return d.damage * game.type_bonus[type_id].damage * game.global_damage

func stat_rate() -> float:
	var d: Dictionary = GameData.TOWERS[type_id]
	return d.fire_rate * game.type_bonus[type_id].rate * game.global_rate

func stat_range() -> float:
	var d: Dictionary = GameData.TOWERS[type_id]
	return d.range * game.type_bonus[type_id].range

func stat_splash() -> float:
	var d: Dictionary = GameData.TOWERS[type_id]
	return d.splash * (game.splash_bonus if d.splash > 0.0 else 1.0)

func _physics_process(delta: float) -> void:
	cooldown -= delta
	var target := _pick_target()
	if target == null:
		return
	_gun.rotation = (target.global_position - global_position).angle() + _rot_offset
	if cooldown <= 0.0:
		_fire(target)
		cooldown = 1.0 / stat_rate()

## Target the enemy furthest along the path within range ("first" priority).
func _pick_target() -> Enemy:
	var best: Enemy = null
	var best_progress := -1.0
	var r := stat_range()
	for e in game.enemies_node.get_children():
		if not (e is Enemy):
			continue
		if e.hp <= 0.0:
			continue
		if global_position.distance_to(e.global_position) > r:
			continue
		if e.progress > best_progress:
			best_progress = e.progress
			best = e
	return best

func _fire(target: Enemy) -> void:
	var d: Dictionary = GameData.TOWERS[type_id]
	var muzzle := global_position + Vector2.RIGHT.rotated(_gun.rotation - _rot_offset) * 26.0
	game.spawn_flash(muzzle, 0.35)
	game.sfx.play("shoot_" + type_id)
	var p := Projectile.new()
	game.projectiles_node.add_child(p)
	p.global_position = muzzle
	p.setup(self, target, {
		damage = stat_damage(),
		speed = d.proj_speed,
		splash = stat_splash(),
		slow = d.slow,
		slow_time = d.slow_time,
		tex = d.proj_tex,
		tint = d.proj_tint,
	})
