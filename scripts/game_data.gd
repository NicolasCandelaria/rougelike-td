class_name GameData
## Central balance tables. Edit values here to rebalance the game.
## Nothing in this file contains logic beyond wave scaling helpers.

static var selected_map_index := 0

const TOWERS := {
	"gatling": {
		name = "Gatling", cost = 50,
		damage = 6.0, range = 160.0, fire_rate = 4.0,
		proj_speed = 620.0, splash = 0.0, slow = 0.0, slow_time = 0.0,
		base_tex = "res://assets/sprites/tower_base_a.png",
		gun_tex = "res://assets/sprites/gun_gatling.png",
		gun_rot_offset = 0.0, gun_tint = Color.WHITE,
		proj_tex = "res://assets/sprites/proj_bullet.png",
		proj_tint = Color.WHITE,
		desc = "Fast single-target fire.",
	},
	"cannon": {
		name = "Cannon", cost = 90,
		damage = 24.0, range = 180.0, fire_rate = 0.8,
		proj_speed = 420.0, splash = 72.0, slow = 0.0, slow_time = 0.0,
		base_tex = "res://assets/sprites/tower_base_b.png",
		gun_tex = "res://assets/sprites/gun_cannon.png",
		gun_rot_offset = 0.0, gun_tint = Color.WHITE,
		proj_tex = "res://assets/sprites/proj_shell.png",
		proj_tint = Color.WHITE,
		desc = "Slow splash damage.",
	},
	"frost": {
		name = "Frost", cost = 70,
		damage = 3.0, range = 150.0, fire_rate = 1.2,
		proj_speed = 480.0, splash = 56.0, slow = 0.45, slow_time = 2.0,
		base_tex = "res://assets/sprites/tower_base_c.png",
		gun_tex = "res://assets/sprites/gun_frost.png",
		gun_rot_offset = PI / 2.0, gun_tint = Color(0.6, 0.85, 1.0),
		proj_tex = "res://assets/sprites/proj_bullet.png",
		proj_tint = Color(0.5, 0.85, 1.0),
		desc = "Slows enemies in an area.",
	},
	"sniper": {
		name = "Sniper", cost = 120,
		damage = 65.0, range = 330.0, fire_rate = 0.4,
		proj_speed = 900.0, splash = 0.0, slow = 0.0, slow_time = 0.0,
		base_tex = "res://assets/sprites/tower_base_d.png",
		gun_tex = "res://assets/sprites/gun_sniper.png",
		gun_rot_offset = PI / 2.0, gun_tint = Color.WHITE,
		proj_tex = "res://assets/sprites/proj_rocket.png",
		proj_tint = Color.WHITE,
		desc = "Huge damage, long range, slow.",
	},
}

const ENEMIES := {
	"grunt": {
		name = "Grunt", hp = 32.0, speed = 70.0, bounty = 8, armor = 0.0,
		tex = "res://assets/sprites/enemy_grunt.png", scale = 1.0, base_damage = 5,
	},
	"runner": {
		name = "Runner", hp = 18.0, speed = 135.0, bounty = 6, armor = 0.0,
		tex = "res://assets/sprites/enemy_runner.png", scale = 1.0, base_damage = 4,
	},
	"tank": {
		name = "Tank", hp = 170.0, speed = 42.0, bounty = 22, armor = 4.0,
		tex = "res://assets/sprites/enemy_tank.png", scale = 1.0, base_damage = 12,
	},
	"swarm": {
		name = "Swarm", hp = 8.0, speed = 95.0, bounty = 2, armor = 0.0,
		tex = "res://assets/sprites/enemy_swarm.png", scale = 0.85, base_damage = 2,
	},
	"shield": {
		name = "Shield", hp = 55.0, speed = 58.0, bounty = 14, armor = 1.0,
		tex = "res://assets/sprites/enemy_tank.png", scale = 0.95, base_damage = 6,
		tint = Color(0.55, 0.75, 1.0), shield_cd = 1.0,
	},
	"healer": {
		name = "Healer", hp = 40.0, speed = 52.0, bounty = 16, armor = 0.0,
		tex = "res://assets/sprites/enemy_grunt.png", scale = 1.0, base_damage = 4,
		tint = Color(0.45, 1.0, 0.55), heal_radius = 90.0, heal_amount = 6.0, heal_interval = 1.4,
	},
	"splitter": {
		name = "Splitter", hp = 48.0, speed = 68.0, bounty = 12, armor = 0.0,
		tex = "res://assets/sprites/enemy_swarm.png", scale = 1.05, base_damage = 5,
		tint = Color(1.0, 0.65, 0.35), split_into = 2, split_type = "grunt", split_hp_mult = 0.45,
	},
}

## Each wave = array of spawn groups.
## t = enemy type, n = count, gap = seconds between spawns, delay = start offset.
const WAVES := [
	[{t = "grunt", n = 6, gap = 1.1, delay = 0.0}],
	[{t = "grunt", n = 9, gap = 0.9, delay = 0.0}],
	[{t = "grunt", n = 6, gap = 1.0, delay = 0.0}, {t = "runner", n = 4, gap = 0.6, delay = 4.0}],
	[{t = "runner", n = 8, gap = 0.55, delay = 0.0}, {t = "grunt", n = 5, gap = 1.0, delay = 3.0}],
	[{t = "swarm", n = 14, gap = 0.35, delay = 0.0}, {t = "grunt", n = 5, gap = 1.0, delay = 5.0}],
	[{t = "tank", n = 2, gap = 4.0, delay = 0.0}, {t = "grunt", n = 8, gap = 0.8, delay = 1.5}],
	[{t = "runner", n = 10, gap = 0.5, delay = 0.0}, {t = "swarm", n = 10, gap = 0.35, delay = 4.0}],
	[{t = "grunt", n = 12, gap = 0.7, delay = 0.0}, {t = "tank", n = 2, gap = 5.0, delay = 3.0}],
	[{t = "swarm", n = 20, gap = 0.3, delay = 0.0}, {t = "runner", n = 6, gap = 0.5, delay = 5.0}],
	[{t = "tank", n = 4, gap = 3.0, delay = 0.0}, {t = "grunt", n = 10, gap = 0.7, delay = 2.0}],
	[{t = "grunt", n = 14, gap = 0.6, delay = 0.0}, {t = "runner", n = 8, gap = 0.5, delay = 4.0}],
	[{t = "tank", n = 3, gap = 3.0, delay = 0.0}, {t = "swarm", n = 16, gap = 0.3, delay = 2.0}],
	[{t = "runner", n = 14, gap = 0.4, delay = 0.0}, {t = "tank", n = 2, gap = 4.0, delay = 5.0}],
	[{t = "grunt", n = 12, gap = 0.6, delay = 0.0}, {t = "swarm", n = 18, gap = 0.28, delay = 3.0}],
	[{t = "tank", n = 5, gap = 2.5, delay = 0.0}, {t = "runner", n = 10, gap = 0.45, delay = 2.0}],
	[{t = "swarm", n = 26, gap = 0.25, delay = 0.0}, {t = "grunt", n = 10, gap = 0.6, delay = 4.0}],
	[{t = "runner", n = 16, gap = 0.38, delay = 0.0}, {t = "tank", n = 4, gap = 3.0, delay = 3.0}],
	[{t = "grunt", n = 16, gap = 0.5, delay = 0.0}, {t = "swarm", n = 20, gap = 0.25, delay = 3.0}, {t = "tank", n = 3, gap = 4.0, delay = 6.0}],
	[{t = "runner", n = 18, gap = 0.35, delay = 0.0}, {t = "tank", n = 5, gap = 2.5, delay = 4.0}],
	[{t = "tank", n = 7, gap = 2.2, delay = 0.0}, {t = "runner", n = 12, gap = 0.4, delay = 3.0}, {t = "swarm", n = 20, gap = 0.25, delay = 6.0}],
]

const WIN_WAVE := 20

## Map definitions: paths, decorations, and 20-wave tables per map.
const MAPS := [
	{
		id = "meadow",
		name = "Meadow",
		desc = "A gentle valley. Learn the basics.",
		deco_seed = 1234,
		deco_cells = [
			Vector2i(1, 0), Vector2i(5, 0), Vector2i(11, 1), Vector2i(18, 1),
			Vector2i(1, 4), Vector2i(9, 4), Vector2i(17, 6), Vector2i(2, 6),
			Vector2i(7, 9), Vector2i(14, 9),
		],
		paths = [{
			points = [
				Vector2i(0, 2), Vector2i(15, 2), Vector2i(15, 5),
				Vector2i(3, 5), Vector2i(3, 8), Vector2i(19, 8),
			],
			spawn_offset = Vector2(-64, 0),
		}],
		hp_scale = 1.0,
	},
	{
		id = "canyon",
		name = "Canyon",
		desc = "Narrow paths. Shield enemies appear.",
		deco_seed = 2345,
		deco_cells = [
			Vector2i(2, 0), Vector2i(10, 0), Vector2i(17, 2), Vector2i(4, 3),
			Vector2i(12, 6), Vector2i(18, 8), Vector2i(6, 9),
		],
		paths = [{
			points = [
				Vector2i(0, 4), Vector2i(8, 4), Vector2i(8, 1),
				Vector2i(16, 1), Vector2i(16, 7), Vector2i(19, 7),
			],
			spawn_offset = Vector2(-64, 0),
		}],
		hp_scale = 1.08,
	},
	{
		id = "crossroads",
		name = "Crossroads",
		desc = "Two entrances merge. Healers support the horde.",
		deco_seed = 3456,
		deco_cells = [
			Vector2i(3, 0), Vector2i(14, 0), Vector2i(1, 5), Vector2i(18, 5),
			Vector2i(5, 9), Vector2i(15, 9),
		],
		paths = [
			{
				points = [Vector2i(0, 2), Vector2i(8, 2), Vector2i(8, 5), Vector2i(19, 5)],
				spawn_offset = Vector2(-64, 0),
			},
			{
				points = [Vector2i(0, 8), Vector2i(8, 8), Vector2i(8, 5), Vector2i(19, 5)],
				spawn_offset = Vector2(-64, 0),
			},
		],
		hp_scale = 1.12,
	},
	{
		id = "fracture",
		name = "Fracture",
		desc = "Splitters break into weaker foes on death.",
		deco_seed = 4567,
		deco_cells = [
			Vector2i(1, 1), Vector2i(9, 0), Vector2i(17, 3), Vector2i(4, 6),
			Vector2i(14, 8), Vector2i(2, 9),
		],
		paths = [{
			points = [
				Vector2i(0, 5), Vector2i(6, 5), Vector2i(6, 2),
				Vector2i(12, 2), Vector2i(12, 7), Vector2i(19, 7),
			],
			spawn_offset = Vector2(-64, 0),
		}],
		hp_scale = 1.16,
	},
	{
		id = "siege",
		name = "Siege",
		desc = "Three entrances. All special enemies mixed.",
		deco_seed = 5678,
		deco_cells = [
			Vector2i(2, 3), Vector2i(16, 2), Vector2i(1, 7), Vector2i(18, 8),
		],
		paths = [
			{points = [Vector2i(0, 1), Vector2i(10, 1), Vector2i(10, 4), Vector2i(19, 4)], spawn_offset = Vector2(-64, 0)},
			{points = [Vector2i(0, 5), Vector2i(10, 5), Vector2i(10, 4), Vector2i(19, 4)], spawn_offset = Vector2(-64, 0)},
			{points = [Vector2i(0, 9), Vector2i(10, 9), Vector2i(10, 4), Vector2i(19, 4)], spawn_offset = Vector2(-64, 0)},
		],
		hp_scale = 1.22,
	},
	{
		id = "citadel",
		name = "Citadel",
		desc = "The final stand. Maximum pressure.",
		deco_seed = 6789,
		deco_cells = [
			Vector2i(4, 0), Vector2i(15, 1), Vector2i(1, 6), Vector2i(18, 6), Vector2i(8, 9),
		],
		paths = [
			{points = [Vector2i(0, 0), Vector2i(7, 0), Vector2i(7, 4), Vector2i(14, 4), Vector2i(14, 8), Vector2i(19, 8)], spawn_offset = Vector2(-64, 0)},
			{points = [Vector2i(0, 5), Vector2i(7, 5), Vector2i(7, 4), Vector2i(14, 4), Vector2i(14, 8), Vector2i(19, 8)], spawn_offset = Vector2(-64, 0)},
			{points = [Vector2i(0, 9), Vector2i(7, 9), Vector2i(7, 8), Vector2i(14, 8), Vector2i(19, 8)], spawn_offset = Vector2(-64, 0)},
		],
		hp_scale = 1.30,
	},
]

static func map_count() -> int:
	return MAPS.size()

static func map_by_index(index: int) -> Dictionary:
	return MAPS[clampi(index, 0, MAPS.size() - 1)]

static func map_index_by_id(id: String) -> int:
	for i in range(MAPS.size()):
		if MAPS[i].id == id:
			return i
	return 0

## Per-wave enemy scaling. Multiplicative on HP, mild on bounty.
static func hp_mult(wave: int, map_index := 0) -> float:
	var scale: float = map_by_index(map_index).get("hp_scale", 1.0)
	return pow(1.13, wave - 1) * scale

static func bounty_mult(wave: int) -> float:
	return 1.0 + 0.04 * (wave - 1)

## Endless mode: procedurally generated waves past WIN_WAVE.
static func endless_wave(wave: int, map_index := 0) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = wave * 7919 + map_index * 997
	var groups := []
	var budget := 10 + (wave - WIN_WAVE) * 4
	var types := ["grunt", "runner", "tank", "swarm", "shield", "healer", "splitter"]
	var delay := 0.0
	var path_count: int = map_by_index(map_index).paths.size()
	while budget > 0:
		var t: String = types[rng.randi_range(0, types.size() - 1)]
		var cost := 5 if t in ["tank", "shield", "healer", "splitter"] else 1
		var n: int = clampi(rng.randi_range(3, 9), 1, maxi(1, budget / cost))
		var spawn := rng.randi_range(0, path_count - 1) if path_count > 1 else 0
		groups.append({t = t, n = n, gap = maxf(0.2, 0.8 - wave * 0.01), delay = delay, spawn = spawn})
		budget -= n * cost
		delay += rng.randf_range(1.5, 4.0)
	return groups

static func map_waves(map_index: int) -> Array:
	match map_index:
		0: return WAVES
		1: return _canyon_waves()
		2: return _crossroads_waves()
		3: return _fracture_waves()
		4: return _siege_waves()
		5: return _citadel_waves()
		_: return WAVES

static func wave_groups(wave: int, map_index := 0) -> Array:
	var waves: Array = map_waves(map_index)
	if wave <= waves.size():
		return waves[wave - 1]
	return endless_wave(wave, map_index)

static func _canyon_waves() -> Array:
	return [
		[{t = "grunt", n = 7, gap = 1.0, delay = 0.0}],
		[{t = "grunt", n = 10, gap = 0.85, delay = 0.0}],
		[{t = "runner", n = 6, gap = 0.6, delay = 0.0}, {t = "grunt", n = 5, gap = 1.0, delay = 3.0}],
		[{t = "shield", n = 2, gap = 3.5, delay = 0.0}, {t = "grunt", n = 6, gap = 0.9, delay = 1.0}],
		[{t = "swarm", n = 12, gap = 0.35, delay = 0.0}, {t = "runner", n = 5, gap = 0.55, delay = 4.0}],
		[{t = "tank", n = 2, gap = 4.0, delay = 0.0}, {t = "shield", n = 2, gap = 3.0, delay = 2.0}],
		[{t = "grunt", n = 10, gap = 0.75, delay = 0.0}, {t = "shield", n = 3, gap = 2.5, delay = 3.0}],
		[{t = "runner", n = 12, gap = 0.45, delay = 0.0}, {t = "swarm", n = 10, gap = 0.3, delay = 4.0}],
		[{t = "shield", n = 4, gap = 2.2, delay = 0.0}, {t = "tank", n = 2, gap = 4.0, delay = 2.0}],
		[{t = "grunt", n = 14, gap = 0.6, delay = 0.0}, {t = "shield", n = 3, gap = 2.0, delay = 4.0}],
		[{t = "swarm", n = 18, gap = 0.28, delay = 0.0}, {t = "runner", n = 8, gap = 0.45, delay = 3.0}],
		[{t = "tank", n = 3, gap = 3.0, delay = 0.0}, {t = "shield", n = 5, gap = 2.0, delay = 2.0}],
		[{t = "runner", n = 14, gap = 0.38, delay = 0.0}, {t = "shield", n = 4, gap = 2.0, delay = 3.0}],
		[{t = "grunt", n = 12, gap = 0.55, delay = 0.0}, {t = "tank", n = 3, gap = 3.5, delay = 3.0}],
		[{t = "shield", n = 6, gap = 1.8, delay = 0.0}, {t = "swarm", n = 16, gap = 0.28, delay = 2.0}],
		[{t = "runner", n = 16, gap = 0.35, delay = 0.0}, {t = "tank", n = 3, gap = 3.0, delay = 3.0}],
		[{t = "shield", n = 5, gap = 2.0, delay = 0.0}, {t = "grunt", n = 14, gap = 0.5, delay = 2.0}],
		[{t = "tank", n = 4, gap = 2.8, delay = 0.0}, {t = "shield", n = 5, gap = 1.8, delay = 2.0}],
		[{t = "runner", n = 18, gap = 0.32, delay = 0.0}, {t = "shield", n = 4, gap = 2.0, delay = 4.0}],
		[{t = "shield", n = 8, gap = 1.6, delay = 0.0}, {t = "tank", n = 5, gap = 2.5, delay = 3.0}, {t = "runner", n = 10, gap = 0.4, delay = 5.0}],
	]

static func _crossroads_waves() -> Array:
	return [
		[{t = "grunt", n = 4, gap = 1.0, delay = 0.0, spawn = 0}, {t = "grunt", n = 4, gap = 1.0, delay = 2.0, spawn = 1}],
		[{t = "runner", n = 5, gap = 0.6, delay = 0.0, spawn = 0}, {t = "grunt", n = 5, gap = 0.9, delay = 1.5, spawn = 1}],
		[{t = "swarm", n = 10, gap = 0.35, delay = 0.0, spawn = 0}, {t = "swarm", n = 10, gap = 0.35, delay = 1.0, spawn = 1}],
		[{t = "healer", n = 2, gap = 4.0, delay = 0.0, spawn = 0}, {t = "grunt", n = 8, gap = 0.8, delay = 1.0, spawn = 1}],
		[{t = "grunt", n = 8, gap = 0.7, delay = 0.0, spawn = 0}, {t = "runner", n = 6, gap = 0.55, delay = 0.0, spawn = 1}],
		[{t = "healer", n = 3, gap = 3.5, delay = 0.0, spawn = 1}, {t = "tank", n = 2, gap = 4.0, delay = 2.0, spawn = 0}],
		[{t = "runner", n = 10, gap = 0.45, delay = 0.0, spawn = 0}, {t = "healer", n = 2, gap = 3.0, delay = 2.0, spawn = 1}],
		[{t = "swarm", n = 14, gap = 0.3, delay = 0.0, spawn = 0}, {t = "grunt", n = 8, gap = 0.7, delay = 0.0, spawn = 1}],
		[{t = "healer", n = 4, gap = 2.8, delay = 0.0, spawn = 0}, {t = "tank", n = 2, gap = 4.0, delay = 1.0, spawn = 1}],
		[{t = "grunt", n = 12, gap = 0.6, delay = 0.0, spawn = 0}, {t = "runner", n = 10, gap = 0.4, delay = 0.0, spawn = 1}],
		[{t = "healer", n = 3, gap = 2.5, delay = 0.0, spawn = 1}, {t = "shield", n = 3, gap = 2.5, delay = 2.0, spawn = 0}],
		[{t = "swarm", n = 20, gap = 0.25, delay = 0.0, spawn = 0}, {t = "healer", n = 3, gap = 2.5, delay = 3.0, spawn = 1}],
		[{t = "tank", n = 3, gap = 3.0, delay = 0.0, spawn = 0}, {t = "runner", n = 12, gap = 0.38, delay = 0.0, spawn = 1}],
		[{t = "healer", n = 5, gap = 2.2, delay = 0.0, spawn = 0}, {t = "grunt", n = 14, gap = 0.5, delay = 2.0, spawn = 1}],
		[{t = "runner", n = 16, gap = 0.35, delay = 0.0, spawn = 0}, {t = "healer", n = 4, gap = 2.0, delay = 0.0, spawn = 1}],
		[{t = "tank", n = 4, gap = 2.8, delay = 0.0, spawn = 0}, {t = "healer", n = 4, gap = 2.0, delay = 2.0, spawn = 1}],
		[{t = "shield", n = 4, gap = 2.0, delay = 0.0, spawn = 0}, {t = "healer", n = 4, gap = 2.0, delay = 0.0, spawn = 1}],
		[{t = "swarm", n = 24, gap = 0.22, delay = 0.0, spawn = 0}, {t = "healer", n = 5, gap = 1.8, delay = 2.0, spawn = 1}],
		[{t = "runner", n = 18, gap = 0.32, delay = 0.0, spawn = 0}, {t = "tank", n = 4, gap = 2.5, delay = 0.0, spawn = 1}],
		[{t = "healer", n = 6, gap = 1.6, delay = 0.0, spawn = 0}, {t = "shield", n = 5, gap = 1.8, delay = 2.0, spawn = 1}, {t = "tank", n = 4, gap = 2.5, delay = 4.0, spawn = 0}],
	]

static func _fracture_waves() -> Array:
	return [
		[{t = "grunt", n = 8, gap = 0.9, delay = 0.0}],
		[{t = "splitter", n = 3, gap = 2.5, delay = 0.0}, {t = "grunt", n = 6, gap = 0.9, delay = 2.0}],
		[{t = "runner", n = 8, gap = 0.55, delay = 0.0}, {t = "splitter", n = 4, gap = 2.0, delay = 3.0}],
		[{t = "swarm", n = 14, gap = 0.32, delay = 0.0}, {t = "splitter", n = 3, gap = 2.2, delay = 3.0}],
		[{t = "splitter", n = 5, gap = 1.8, delay = 0.0}, {t = "grunt", n = 10, gap = 0.7, delay = 2.0}],
		[{t = "tank", n = 2, gap = 4.0, delay = 0.0}, {t = "splitter", n = 4, gap = 2.0, delay = 2.0}],
		[{t = "runner", n = 12, gap = 0.42, delay = 0.0}, {t = "splitter", n = 5, gap = 1.6, delay = 3.0}],
		[{t = "splitter", n = 6, gap = 1.5, delay = 0.0}, {t = "swarm", n = 16, gap = 0.28, delay = 2.0}],
		[{t = "grunt", n = 12, gap = 0.6, delay = 0.0}, {t = "splitter", n = 6, gap = 1.5, delay = 3.0}],
		[{t = "shield", n = 3, gap = 2.5, delay = 0.0}, {t = "splitter", n = 5, gap = 1.6, delay = 2.0}],
		[{t = "splitter", n = 7, gap = 1.4, delay = 0.0}, {t = "runner", n = 12, gap = 0.38, delay = 2.0}],
		[{t = "tank", n = 3, gap = 3.0, delay = 0.0}, {t = "splitter", n = 6, gap = 1.5, delay = 2.0}],
		[{t = "swarm", n = 22, gap = 0.24, delay = 0.0}, {t = "splitter", n = 6, gap = 1.4, delay = 3.0}],
		[{t = "splitter", n = 8, gap = 1.3, delay = 0.0}, {t = "healer", n = 3, gap = 2.5, delay = 2.0}],
		[{t = "runner", n = 16, gap = 0.35, delay = 0.0}, {t = "splitter", n = 7, gap = 1.4, delay = 3.0}],
		[{t = "tank", n = 4, gap = 2.8, delay = 0.0}, {t = "splitter", n = 8, gap = 1.2, delay = 2.0}],
		[{t = "splitter", n = 9, gap = 1.2, delay = 0.0}, {t = "shield", n = 4, gap = 2.0, delay = 2.0}],
		[{t = "grunt", n = 16, gap = 0.48, delay = 0.0}, {t = "splitter", n = 8, gap = 1.2, delay = 3.0}],
		[{t = "runner", n = 18, gap = 0.32, delay = 0.0}, {t = "splitter", n = 8, gap = 1.2, delay = 3.0}],
		[{t = "splitter", n = 10, gap = 1.1, delay = 0.0}, {t = "tank", n = 5, gap = 2.5, delay = 3.0}, {t = "healer", n = 4, gap = 2.0, delay = 5.0}],
	]

static func _siege_waves() -> Array:
	return [
		[{t = "grunt", n = 3, gap = 1.0, delay = 0.0, spawn = 0}, {t = "grunt", n = 3, gap = 1.0, delay = 1.0, spawn = 1}, {t = "grunt", n = 3, gap = 1.0, delay = 2.0, spawn = 2}],
		[{t = "runner", n = 4, gap = 0.6, delay = 0.0, spawn = 0}, {t = "runner", n = 4, gap = 0.6, delay = 1.0, spawn = 1}, {t = "runner", n = 4, gap = 0.6, delay = 2.0, spawn = 2}],
		[{t = "shield", n = 2, gap = 3.0, delay = 0.0, spawn = 0}, {t = "grunt", n = 6, gap = 0.8, delay = 0.0, spawn = 1}],
		[{t = "healer", n = 2, gap = 3.5, delay = 0.0, spawn = 2}, {t = "swarm", n = 10, gap = 0.35, delay = 0.0, spawn = 0}],
		[{t = "splitter", n = 3, gap = 2.0, delay = 0.0, spawn = 1}, {t = "runner", n = 6, gap = 0.5, delay = 0.0, spawn = 2}],
		[{t = "grunt", n = 6, gap = 0.8, delay = 0.0, spawn = 0}, {t = "shield", n = 2, gap = 2.5, delay = 0.0, spawn = 1}, {t = "healer", n = 2, gap = 3.0, delay = 0.0, spawn = 2}],
		[{t = "tank", n = 2, gap = 4.0, delay = 0.0, spawn = 0}, {t = "splitter", n = 4, gap = 1.8, delay = 0.0, spawn = 1}],
		[{t = "swarm", n = 12, gap = 0.3, delay = 0.0, spawn = 0}, {t = "healer", n = 3, gap = 2.5, delay = 0.0, spawn = 2}, {t = "runner", n = 6, gap = 0.5, delay = 0.0, spawn = 1}],
		[{t = "shield", n = 3, gap = 2.2, delay = 0.0, spawn = 0}, {t = "splitter", n = 4, gap = 1.6, delay = 0.0, spawn = 1}, {t = "healer", n = 2, gap = 2.8, delay = 0.0, spawn = 2}],
		[{t = "grunt", n = 8, gap = 0.7, delay = 0.0, spawn = 0}, {t = "runner", n = 8, gap = 0.45, delay = 0.0, spawn = 1}, {t = "swarm", n = 10, gap = 0.32, delay = 0.0, spawn = 2}],
		[{t = "healer", n = 4, gap = 2.2, delay = 0.0, spawn = 0}, {t = "shield", n = 4, gap = 2.0, delay = 0.0, spawn = 1}, {t = "splitter", n = 4, gap = 1.6, delay = 0.0, spawn = 2}],
		[{t = "tank", n = 3, gap = 3.0, delay = 0.0, spawn = 0}, {t = "splitter", n = 5, gap = 1.5, delay = 0.0, spawn = 1}, {t = "runner", n = 10, gap = 0.4, delay = 0.0, spawn = 2}],
		[{t = "swarm", n = 18, gap = 0.26, delay = 0.0, spawn = 0}, {t = "healer", n = 4, gap = 2.0, delay = 0.0, spawn = 1}, {t = "shield", n = 3, gap = 2.2, delay = 0.0, spawn = 2}],
		[{t = "splitter", n = 6, gap = 1.4, delay = 0.0, spawn = 0}, {t = "tank", n = 2, gap = 3.5, delay = 0.0, spawn = 1}, {t = "runner", n = 12, gap = 0.38, delay = 0.0, spawn = 2}],
		[{t = "healer", n = 5, gap = 1.8, delay = 0.0, spawn = 0}, {t = "shield", n = 5, gap = 1.8, delay = 0.0, spawn = 1}, {t = "splitter", n = 5, gap = 1.5, delay = 0.0, spawn = 2}],
		[{t = "runner", n = 14, gap = 0.35, delay = 0.0, spawn = 0}, {t = "tank", n = 3, gap = 2.8, delay = 0.0, spawn = 1}, {t = "swarm", n = 16, gap = 0.28, delay = 0.0, spawn = 2}],
		[{t = "splitter", n = 7, gap = 1.3, delay = 0.0, spawn = 0}, {t = "healer", n = 5, gap = 1.6, delay = 0.0, spawn = 1}, {t = "shield", n = 5, gap = 1.6, delay = 0.0, spawn = 2}],
		[{t = "tank", n = 4, gap = 2.5, delay = 0.0, spawn = 0}, {t = "runner", n = 14, gap = 0.35, delay = 0.0, spawn = 1}, {t = "splitter", n = 6, gap = 1.4, delay = 0.0, spawn = 2}],
		[{t = "healer", n = 5, gap = 1.5, delay = 0.0, spawn = 0}, {t = "shield", n = 5, gap = 1.5, delay = 0.0, spawn = 1}, {t = "splitter", n = 6, gap = 1.3, delay = 0.0, spawn = 2}],
		[{t = "shield", n = 4, gap = 1.5, delay = 0.0, spawn = 0}, {t = "healer", n = 4, gap = 1.5, delay = 0.0, spawn = 1}, {t = "splitter", n = 5, gap = 1.2, delay = 0.0, spawn = 2}, {t = "tank", n = 4, gap = 2.2, delay = 2.0, spawn = 0}],
	]

static func _citadel_waves() -> Array:
	return [
		[{t = "grunt", n = 4, gap = 0.9, delay = 0.0, spawn = 0}, {t = "grunt", n = 4, gap = 0.9, delay = 0.5, spawn = 1}, {t = "grunt", n = 4, gap = 0.9, delay = 1.0, spawn = 2}],
		[{t = "shield", n = 2, gap = 2.5, delay = 0.0, spawn = 0}, {t = "runner", n = 6, gap = 0.5, delay = 0.0, spawn = 1}],
		[{t = "healer", n = 3, gap = 2.5, delay = 0.0, spawn = 2}, {t = "splitter", n = 4, gap = 1.6, delay = 0.0, spawn = 0}],
		[{t = "swarm", n = 14, gap = 0.28, delay = 0.0, spawn = 0}, {t = "shield", n = 3, gap = 2.0, delay = 0.0, spawn = 1}, {t = "runner", n = 6, gap = 0.45, delay = 0.0, spawn = 2}],
		[{t = "tank", n = 2, gap = 3.5, delay = 0.0, spawn = 0}, {t = "healer", n = 3, gap = 2.2, delay = 0.0, spawn = 1}, {t = "splitter", n = 5, gap = 1.4, delay = 0.0, spawn = 2}],
		[{t = "shield", n = 4, gap = 1.8, delay = 0.0, spawn = 0}, {t = "splitter", n = 5, gap = 1.4, delay = 0.0, spawn = 1}, {t = "healer", n = 3, gap = 2.0, delay = 0.0, spawn = 2}],
		[{t = "runner", n = 12, gap = 0.38, delay = 0.0, spawn = 0}, {t = "tank", n = 2, gap = 3.0, delay = 0.0, spawn = 1}, {t = "swarm", n = 14, gap = 0.26, delay = 0.0, spawn = 2}],
		[{t = "healer", n = 4, gap = 1.8, delay = 0.0, spawn = 0}, {t = "shield", n = 4, gap = 1.8, delay = 0.0, spawn = 1}, {t = "splitter", n = 6, gap = 1.2, delay = 0.0, spawn = 2}],
		[{t = "splitter", n = 7, gap = 1.2, delay = 0.0, spawn = 0}, {t = "tank", n = 3, gap = 2.8, delay = 0.0, spawn = 1}, {t = "runner", n = 10, gap = 0.38, delay = 0.0, spawn = 2}],
		[{t = "shield", n = 5, gap = 1.6, delay = 0.0, spawn = 0}, {t = "healer", n = 5, gap = 1.6, delay = 0.0, spawn = 1}, {t = "swarm", n = 18, gap = 0.24, delay = 0.0, spawn = 2}],
		[{t = "tank", n = 3, gap = 2.5, delay = 0.0, spawn = 0}, {t = "splitter", n = 7, gap = 1.1, delay = 0.0, spawn = 1}, {t = "healer", n = 4, gap = 1.6, delay = 0.0, spawn = 2}],
		[{t = "runner", n = 14, gap = 0.32, delay = 0.0, spawn = 0}, {t = "shield", n = 5, gap = 1.5, delay = 0.0, spawn = 1}, {t = "splitter", n = 6, gap = 1.2, delay = 0.0, spawn = 2}],
		[{t = "healer", n = 6, gap = 1.4, delay = 0.0, spawn = 0}, {t = "tank", n = 4, gap = 2.2, delay = 0.0, spawn = 1}, {t = "swarm", n = 20, gap = 0.22, delay = 0.0, spawn = 2}],
		[{t = "splitter", n = 8, gap = 1.0, delay = 0.0, spawn = 0}, {t = "shield", n = 6, gap = 1.4, delay = 0.0, spawn = 1}, {t = "healer", n = 5, gap = 1.4, delay = 0.0, spawn = 2}],
		[{t = "tank", n = 5, gap = 2.0, delay = 0.0, spawn = 0}, {t = "runner", n = 16, gap = 0.3, delay = 0.0, spawn = 1}, {t = "splitter", n = 7, gap = 1.1, delay = 0.0, spawn = 2}],
		[{t = "shield", n = 6, gap = 1.3, delay = 0.0, spawn = 0}, {t = "healer", n = 6, gap = 1.3, delay = 0.0, spawn = 1}, {t = "splitter", n = 7, gap = 1.0, delay = 0.0, spawn = 2}],
		[{t = "swarm", n = 24, gap = 0.2, delay = 0.0, spawn = 0}, {t = "tank", n = 4, gap = 2.2, delay = 0.0, spawn = 1}, {t = "runner", n = 14, gap = 0.32, delay = 0.0, spawn = 2}],
		[{t = "splitter", n = 9, gap = 0.95, delay = 0.0, spawn = 0}, {t = "healer", n = 6, gap = 1.2, delay = 0.0, spawn = 1}, {t = "shield", n = 6, gap = 1.2, delay = 0.0, spawn = 2}],
		[{t = "tank", n = 5, gap = 2.0, delay = 0.0, spawn = 0}, {t = "runner", n = 18, gap = 0.28, delay = 0.0, spawn = 1}, {t = "splitter", n = 8, gap = 1.0, delay = 0.0, spawn = 2}],
		[{t = "shield", n = 6, gap = 1.2, delay = 0.0, spawn = 0}, {t = "healer", n = 6, gap = 1.2, delay = 0.0, spawn = 1}, {t = "splitter", n = 8, gap = 0.95, delay = 0.0, spawn = 2}, {t = "tank", n = 6, gap = 1.8, delay = 2.0, spawn = 0}],
	]

## ---------- Reward cards ----------
## Relics are one-time run-wide passives. Applied in game.gd/_apply_reward.
const RELICS := {
	"cryo": {title = "Cryo Amplifier", desc = "Slow effects are 25% stronger.",
		icon = "res://assets/sprites/icons/icon_cryo.png"},
	"lucky": {title = "Lucky Strike", desc = "Kills have a 10% chance to drop +5 gold.",
		icon = "res://assets/sprites/icons/icon_lucky.png"},
	"bunker": {title = "Reinforced Bunker", desc = "+50 max base HP, heal 50.",
		icon = "res://assets/sprites/icons/icon_bunker.png"},
	"blast": {title = "Blast Radius", desc = "Splash radius +30%.",
		icon = "res://assets/sprites/icons/icon_blast.png"},
	"bounty5": {title = "Bounty Hunter", desc = "Every 5th kill grants +10 gold.",
		icon = "res://assets/sprites/icons/icon_bounty.png"},
	"scrap": {title = "Scrap Economy", desc = "Towers cost 15% less.",
		icon = "res://assets/sprites/icons/icon_scrap.png"},
	"overcharge": {title = "Overcharge", desc = "All towers +10% damage.",
		icon = "res://assets/sprites/icons/icon_overcharge.png"},
	"swift": {title = "Swift Rounds", desc = "All towers +10% fire rate.",
		icon = "res://assets/sprites/icons/icon_swift.png"},
	"medic": {title = "Field Medic", desc = "Heal 10 base HP after each wave.",
		icon = "res://assets/sprites/icons/icon_medic.png"},
	"bonds": {title = "War Bonds", desc = "+40 gold now, +5 gold each wave end.",
		icon = "res://assets/sprites/icons/icon_bonds.png"},
	"interest": {title = "Interest", desc = "+10% of your gold each wave end (max +50).",
		icon = "res://assets/sprites/icons/icon_interest.png"},
	"ap": {title = "AP Rounds", desc = "All towers ignore enemy armor.",
		icon = "res://assets/sprites/icons/icon_ap.png"},
}

## Curses: powerful relics with a real downside. Applied in game.gd/_apply_reward.
const CURSES := {
	"glass_cannon": {title = "Glass Cannon",
		desc = "+40% tower damage. -20% base max HP.",
		icon = "res://assets/sprites/icons/icon_curse_glass.png"},
	"overclock": {title = "Unstable Overclock",
		desc = "+30% fire rate. Enemies move 15% faster.",
		icon = "res://assets/sprites/icons/icon_curse_clock.png"},
	"blood_money": {title = "Blood Money",
		desc = "+150 gold now. Lose 3 base HP after each wave.",
		icon = "res://assets/sprites/icons/icon_curse_blood.png"},
	"brittle": {title = "Brittle Foundations",
		desc = "Towers cost 25% less. -25% base max HP.",
		icon = "res://assets/sprites/icons/icon_curse_brittle.png"},
}

const UPGRADE_KINDS := {
	"damage": {label = "Damage", amount = 0.25,
		icon = "res://assets/sprites/icons/icon_damage.png"},
	"rate": {label = "Fire Rate", amount = 0.20,
		icon = "res://assets/sprites/icons/icon_rate.png"},
	"range": {label = "Range", amount = 0.15,
		icon = "res://assets/sprites/icons/icon_range.png"},
}

const GOLD_ICON := "res://assets/sprites/icons/icon_gold.png"
