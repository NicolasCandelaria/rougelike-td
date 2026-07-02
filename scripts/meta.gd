extends Node
## Persistent meta-progression, autoloaded as "Meta".
## Cores are earned from run performance and spent in the Upgrades menu.
## Runs themselves still reset to zero; only this layer persists.

const SAVE_PATH := "user://meta.json"

const CORES_PER_WAVE := 2
const KILLS_PER_CORE := 10     # 1 core per 10 kills
const VICTORY_BONUS := 25

## Upgrade table. "amount" is the per-level effect consumed by game.gd.
## max = 1 entries are one-time unlocks.
const UPGRADES := {
	"start_gold": {
		name = "War Funding", amount = 25.0, max = 4,
		costs = [55, 110, 185, 280],
		desc = "+25 starting gold per level.",
	},
	"base_hp": {
		name = "Fortifications", amount = 20.0, max = 4,
		costs = [55, 110, 185, 280],
		desc = "+20 starting base HP per level.",
	},
	"damage": {
		name = "Weapons Lab", amount = 0.05, max = 5,
		costs = [90, 160, 250, 360, 500],
		desc = "All towers +5% damage per level.",
	},
	"rate": {
		name = "Rapid Loaders", amount = 0.04, max = 5,
		costs = [90, 160, 250, 360, 500],
		desc = "All towers +4% fire rate per level.",
	},
	"bounty": {
		name = "Bounty Office", amount = 0.06, max = 4,
		costs = [70, 140, 230, 340],
		desc = "+6% gold from kills per level.",
	},
	"core_gain": {
		name = "Salvage Rig", amount = 0.10, max = 5,
		costs = [80, 150, 240, 350, 480],
		desc = "+10% Cores earned from runs per level.",
	},
	"unlock_cannon": {
		name = "Cannon Blueprint", amount = 0.0, max = 1,
		costs = [220],
		desc = "Start every run with the Cannon unlocked.",
	},
	"unlock_frost": {
		name = "Frost Blueprint", amount = 0.0, max = 1,
		costs = [320],
		desc = "Start every run with the Frost tower unlocked.",
	},
	"unlock_sniper": {
		name = "Sniper Blueprint", amount = 0.0, max = 1,
		costs = [450],
		desc = "Start every run with the Sniper unlocked.",
	},
	"start_relic": {
		name = "Relic Cache", amount = 0.0, max = 1,
		costs = [550],
		desc = "Start every run with a random relic.",
	},
}

var cores := 0
var levels := {}               # id -> purchased level

func _ready() -> void:
	load_data()

func level(id: String) -> int:
	return int(levels.get(id, 0))

## Total effect of an upgrade (amount * level). 0.0 when unpurchased.
func total(id: String) -> float:
	return UPGRADES[id].amount * level(id)

func is_maxed(id: String) -> bool:
	return level(id) >= UPGRADES[id].max

func next_cost(id: String) -> int:
	if is_maxed(id):
		return 0
	return UPGRADES[id].costs[level(id)]

func can_buy(id: String) -> bool:
	return not is_maxed(id) and cores >= next_cost(id)

func buy(id: String) -> bool:
	if not can_buy(id):
		return false
	cores -= next_cost(id)
	levels[id] = level(id) + 1
	save_data()
	return true

## Cores earned for a slice of run performance. Scaled by Salvage Rig.
func calc_cores(waves: int, kills: int, victory: bool) -> int:
	var base := waves * CORES_PER_WAVE + floori(kills / float(KILLS_PER_CORE))
	if victory:
		base += VICTORY_BONUS
	return int(round(base * (1.0 + total("core_gain"))))

func award(amount: int) -> void:
	if amount <= 0:
		return
	cores += amount
	save_data()

## ---------- Persistence ----------
func save_data() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({cores = cores, levels = levels}))

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var data: Variant = JSON.parse_string(f.get_as_text())
	if not (data is Dictionary):
		return
	cores = maxi(0, int(data.get("cores", 0)))
	var lv: Variant = data.get("levels", {})
	if lv is Dictionary:
		for id in lv.keys():
			if UPGRADES.has(id):
				levels[id] = clampi(int(lv[id]), 0, UPGRADES[id].max)
