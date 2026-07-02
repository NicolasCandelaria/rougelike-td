class_name Enemy
extends Node2D

signal died(enemy: Enemy)
signal leaked(enemy: Enemy, damage: int)

var type_id := ""
var hp := 10.0
var hp_max := 10.0
var speed := 60.0
var armor := 0.0
var bounty := 0
var base_damage := 5

var waypoints: PackedVector2Array
var wp_index := 1
var progress := 0.0            # total distance travelled, used for "first" targeting

var slow_factor := 1.0         # 1.0 = no slow; 0.55 = moving at 55% speed
var slow_timer := 0.0

var _sprite: Sprite2D

func setup(id: String, wave: int, path: PackedVector2Array) -> void:
	type_id = id
	var d: Dictionary = GameData.ENEMIES[id]
	hp_max = d.hp * GameData.hp_mult(wave)
	hp = hp_max
	speed = d.speed
	armor = d.armor
	bounty = int(round(d.bounty * GameData.bounty_mult(wave)))
	base_damage = d.base_damage
	waypoints = path
	position = path[0]

	_sprite = Sprite2D.new()
	_sprite.texture = load(d.tex)
	_sprite.scale = Vector2.ONE * d.scale
	add_child(_sprite)
	z_index = 10

func _physics_process(delta: float) -> void:
	if slow_timer > 0.0:
		slow_timer -= delta
		if slow_timer <= 0.0:
			slow_factor = 1.0
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
	var dealt: float = amount if ignore_armor else maxf(1.0, amount - armor)
	hp -= dealt
	_hit_flash()
	queue_redraw()
	if hp <= 0.0:
		died.emit(self)
		queue_free()
	return dealt

func _hit_flash() -> void:
	if not is_instance_valid(_sprite):
		return
	_sprite.self_modulate = Color(1.8, 1.8, 1.8)
	var t := create_tween()
	t.tween_property(_sprite, "self_modulate", Color.WHITE, 0.12)

func apply_slow(factor: float, duration: float) -> void:
	# Keep the strongest slow currently applied.
	slow_factor = minf(slow_factor, factor)
	slow_timer = maxf(slow_timer, duration)
	_sprite.modulate = Color(0.7, 0.85, 1.0)
	var t := create_tween()
	t.tween_interval(duration)
	t.tween_callback(func() -> void:
		if is_instance_valid(_sprite):
			_sprite.modulate = Color.WHITE)

func _draw() -> void:
	if hp >= hp_max:
		return
	var w := 30.0
	var y := -24.0
	draw_rect(Rect2(-w / 2.0, y, w, 4.0), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(-w / 2.0, y, w * clampf(hp / hp_max, 0.0, 1.0), 4.0), Color(0.3, 0.9, 0.3))
