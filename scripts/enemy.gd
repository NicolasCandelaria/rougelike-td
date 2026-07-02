class_name Enemy
extends Node2D

signal died(enemy: Enemy)
signal leaked(enemy: Enemy, damage: int)
signal split_spawn(enemy: Enemy, type_id: String, wave: int, waypoints: PackedVector2Array, pos: Vector2, hp_mult: float)

var type_id := ""
var wave_num := 1
var game_ref: Node
var hp := 10.0
var hp_max := 10.0
var speed := 60.0
var armor := 0.0
var bounty := 0
var base_damage := 5

var waypoints: PackedVector2Array
var wp_index := 1
var progress := 0.0

var slow_factor := 1.0
var slow_timer := 0.0

var shield_cd := 0.0
var _shield_ready := false
var _shield_timer := 0.0

var heal_radius := 0.0
var heal_amount := 0.0
var heal_interval := 0.0
var _heal_timer := 0.0

var split_into := 0
var split_type := "grunt"
var split_hp_mult := 0.5

var _sprite: Sprite2D
var _heal_pulse := 0.0

func setup(id: String, wave: int, path: PackedVector2Array, map_index := 0, g: Node = null) -> void:
	type_id = id
	wave_num = wave
	game_ref = g
	var d: Dictionary = GameData.ENEMIES[id]
	hp_max = d.hp * GameData.hp_mult(wave, map_index)
	hp = hp_max
	speed = d.speed
	armor = d.armor
	bounty = int(round(d.bounty * GameData.bounty_mult(wave)))
	base_damage = d.base_damage
	waypoints = path
	position = path[0]

	shield_cd = d.get("shield_cd", 0.0)
	_shield_ready = shield_cd > 0.0
	_shield_timer = 0.0

	heal_radius = d.get("heal_radius", 0.0)
	heal_amount = d.get("heal_amount", 0.0)
	heal_interval = d.get("heal_interval", 0.0)
	_heal_timer = heal_interval * 0.5 if heal_interval > 0.0 else 0.0

	split_into = d.get("split_into", 0)
	split_type = d.get("split_type", "grunt")
	split_hp_mult = d.get("split_hp_mult", 0.5)

	_sprite = Sprite2D.new()
	_sprite.texture = load(d.tex)
	_sprite.scale = Vector2.ONE * d.scale
	if d.has("tint"):
		_sprite.modulate = d.tint
	add_child(_sprite)
	z_index = 10

func setup_split(id: String, wave: int, path: PackedVector2Array, at: Vector2, hp_mult: float, map_index := 0, g: Node = null) -> void:
	setup(id, wave, path, map_index, g)
	hp_max *= hp_mult
	hp = hp_max
	bounty = maxi(1, int(bounty * 0.5))
	position = at
	wp_index = _nearest_wp_index(at)
	split_into = 0

func _nearest_wp_index(at: Vector2) -> int:
	var best := 1
	var best_d := INF
	for i in range(1, waypoints.size()):
		var d := at.distance_squared_to(waypoints[i])
		if d < best_d:
			best_d = d
			best = i
	return best

func _physics_process(delta: float) -> void:
	if slow_timer > 0.0:
		slow_timer -= delta
		if slow_timer <= 0.0:
			slow_factor = 1.0

	if shield_cd > 0.0:
		if not _shield_ready:
			_shield_timer += delta
			if _shield_timer >= shield_cd:
				_shield_ready = true
				_shield_timer = 0.0

	if heal_radius > 0.0:
		_heal_timer -= delta
		if _heal_timer <= 0.0:
			_heal_timer = heal_interval
			_heal_nearby()
			_heal_pulse = 1.0
		if _heal_pulse > 0.0:
			_heal_pulse = maxf(0.0, _heal_pulse - delta * 2.5)

	if wp_index >= waypoints.size():
		return
	var target := waypoints[wp_index]
	var to_target := target - position
	var step := speed * slow_factor * delta
	progress += step
	if to_target.length() <= step:
		position = target
		wp_index += 1
		if wp_index >= waypoints.size():
			leaked.emit(self, base_damage)
			queue_free()
			return
	else:
		position += to_target.normalized() * step
		_sprite.rotation = to_target.angle() + PI / 2.0
	queue_redraw()

func take_damage(amount: float, ignore_armor := false) -> float:
	if hp <= 0.0:
		return 0.0
	if _shield_ready:
		_shield_ready = false
		_shield_timer = 0.0
		_hit_flash()
		if game_ref != null and game_ref.has_method("spawn_blocked_text"):
			game_ref.spawn_blocked_text(global_position)
		queue_redraw()
		return 0.0
	var dealt: float = amount if ignore_armor else maxf(1.0, amount - armor)
	hp -= dealt
	_hit_flash()
	queue_redraw()
	if hp <= 0.0:
		if split_into > 0:
			for i in range(split_into):
				split_spawn.emit(self, split_type, wave_num, waypoints, position, split_hp_mult)
		died.emit(self)
		queue_free()
	return dealt

func heal(amount: float) -> void:
	if hp <= 0.0:
		return
	hp = minf(hp + amount, hp_max)
	queue_redraw()

func _heal_nearby() -> void:
	var parent := get_parent()
	if parent == null:
		return
	for child in parent.get_children():
		if child == self or not child is Enemy:
			continue
		var other: Enemy = child
		if other.hp >= other.hp_max:
			continue
		if global_position.distance_to(other.global_position) <= heal_radius:
			other.heal(heal_amount)

func _hit_flash() -> void:
	if not is_instance_valid(_sprite):
		return
	_sprite.self_modulate = Color(1.8, 1.8, 1.8)
	var t := create_tween()
	t.tween_property(_sprite, "self_modulate", Color.WHITE, 0.12)

func apply_slow(factor: float, duration: float) -> void:
	slow_factor = minf(slow_factor, factor)
	slow_timer = maxf(slow_timer, duration)
	_sprite.modulate = Color(0.7, 0.85, 1.0)
	var t := create_tween()
	t.tween_interval(duration)
	t.tween_callback(func() -> void:
		if is_instance_valid(_sprite):
			var d: Dictionary = GameData.ENEMIES.get(type_id, {})
			_sprite.modulate = d.get("tint", Color.WHITE))

func _draw() -> void:
	if shield_cd > 0.0 and _shield_ready:
		draw_arc(Vector2.ZERO, 22.0, 0.0, TAU, 24, Color(0.45, 0.75, 1.0, 0.85), 2.5)
	if heal_radius > 0.0 and _heal_pulse > 0.0:
		draw_arc(Vector2.ZERO, 28.0 * _heal_pulse, 0.0, TAU, 24, Color(0.3, 1.0, 0.45, 0.35 * _heal_pulse), 2.0)
	if hp >= hp_max:
		return
	var w := 30.0
	var y := -24.0
	draw_rect(Rect2(-w / 2.0, y, w, 4.0), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(-w / 2.0, y, w * clampf(hp / hp_max, 0.0, 1.0), 4.0), Color(0.3, 0.9, 0.3))
