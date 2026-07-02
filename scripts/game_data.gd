class_name GameData
## Central balance tables. Edit values here to rebalance the game.
## Nothing in this file contains logic beyond wave scaling helpers.

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
		name = "Tank", hp = 150.0, speed = 42.0, bounty = 22, armor = 3.0,
		tex = "res://assets/sprites/enemy_tank.png", scale = 1.0, base_damage = 12,
	},
	"swarm": {
		name = "Swarm", hp = 8.0, speed = 95.0, bounty = 2, armor = 0.0,
		tex = "res://assets/sprites/enemy_swarm.png", scale = 0.85, base_damage = 2,
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

## Per-wave enemy scaling. Multiplicative on HP, mild on bounty.
static func hp_mult(wave: int) -> float:
	return pow(1.13, wave - 1)

static func bounty_mult(wave: int) -> float:
	return 1.0 + 0.04 * (wave - 1)

## Endless mode: procedurally generated waves past WIN_WAVE.
static func endless_wave(wave: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = wave * 7919
	var groups := []
	var budget := 10 + (wave - WIN_WAVE) * 4
	var types := ["grunt", "runner", "tank", "swarm"]
	var delay := 0.0
	while budget > 0:
		var t: String = types[rng.randi_range(0, 3)]
		var cost := 4 if t == "tank" else 1
		var n: int = clampi(rng.randi_range(4, 10), 1, maxi(1, budget / cost))
		groups.append({t = t, n = n, gap = maxf(0.2, 0.8 - wave * 0.01), delay = delay})
		budget -= n * cost
		delay += rng.randf_range(1.5, 4.0)
	return groups

static func wave_groups(wave: int) -> Array:
	if wave <= WAVES.size():
		return WAVES[wave - 1]
	return endless_wave(wave)

## ---------- Reward cards ----------
## Relics are one-time run-wide passives. Applied in game.gd/_apply_reward.
const RELICS := {
	"cryo": {title = "Cryo Amplifier", desc = "Slow effects are 25% stronger."},
	"lucky": {title = "Lucky Strike", desc = "Kills have a 10% chance to drop +5 gold."},
	"bunker": {title = "Reinforced Bunker", desc = "+50 max base HP, heal 50."},
	"blast": {title = "Blast Radius", desc = "Splash radius +30%."},
	"bounty5": {title = "Bounty Hunter", desc = "Every 5th kill grants +10 gold."},
	"scrap": {title = "Scrap Economy", desc = "Towers cost 15% less."},
	"overcharge": {title = "Overcharge", desc = "All towers +10% damage."},
	"swift": {title = "Swift Rounds", desc = "All towers +10% fire rate."},
	"medic": {title = "Field Medic", desc = "Heal 10 base HP after each wave."},
	"bonds": {title = "War Bonds", desc = "+40 gold now, +5 gold each wave end."},
	"interest": {title = "Interest", desc = "+10% of your gold each wave end (max +50)."},
	"ap": {title = "AP Rounds", desc = "All towers ignore enemy armor."},
}

const UPGRADE_KINDS := {
	"damage": {label = "Damage", amount = 0.25},
	"rate": {label = "Fire Rate", amount = 0.20},
	"range": {label = "Range", amount = 0.15},
}
