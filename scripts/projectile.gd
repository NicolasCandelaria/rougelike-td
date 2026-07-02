class_name Projectile
extends Node2D

var tower: Tower
var target: Enemy
var damage := 0.0
var speed := 500.0
var splash := 0.0
var slow := 0.0
var slow_time := 0.0
var _last_dir := Vector2.RIGHT
var _life := 3.0

func setup(from_tower: Tower, to_target: Enemy, params: Dictionary) -> void:
	tower = from_tower
	target = to_target
	damage = params.damage
	speed = params.speed
	splash = params.splash
	slow = params.slow
	slow_time = params.slow_time

	var s := Sprite2D.new()
	s.texture = load(params.tex)
	s.modulate = params.tint
	add_child(s)
	z_index = 12

func _physics_process(delta: float) -> void:
	_life -= delta
	if _life <= 0.0:
		queue_free()
		return
	var aim: Vector2
	if is_instance_valid(target) and target.hp > 0.0:
		aim = target.global_position
		_last_dir = (aim - global_position).normalized()
	else:
		# Target died mid-flight: keep flying straight, expire on lifetime.
		aim = global_position + _last_dir * 1000.0
	var step := speed * delta
	rotation = _last_dir.angle() + PI / 2.0
	if is_instance_valid(target) and global_position.distance_to(aim) <= step + 10.0:
		_impact(aim)
		return
	global_position += _last_dir * step

func _impact(at: Vector2) -> void:
	var game: Node = tower.game if is_instance_valid(tower) else null
	if game == null:
		queue_free()
		return
	var effective_slow := 1.0
	if slow > 0.0:
		# slow is "fraction of speed removed"; cryo relic scales it up.
		effective_slow = clampf(1.0 - slow * game.slow_power, 0.1, 1.0)
	var pierce: bool = game.ignore_armor
	if splash > 0.0:
		for e in game.enemies_node.get_children():
			if e is Enemy and e.hp > 0.0 and at.distance_to(e.global_position) <= splash:
				var dealt: float = e.take_damage(damage, pierce)
				game.spawn_damage_number(e.global_position, dealt)
				if slow > 0.0:
					e.apply_slow(effective_slow, slow_time)
		game.spawn_flash(at, 1.2)
		game.sfx.play("impact_splash")
	else:
		if is_instance_valid(target) and target.hp > 0.0:
			var dealt: float = target.take_damage(damage, pierce)
			game.spawn_damage_number(target.global_position, dealt)
			if slow > 0.0:
				target.apply_slow(effective_slow, slow_time)
		game.spawn_flash(at, 0.6)
	queue_free()
