extends Node2D
## Root controller. Owns run state, tower placement, the reward layer,
## and win/lose flow. Balance lives in game_data.gd, not here.

enum State { BUILD, WAVE, REWARD, GAME_OVER, VICTORY }

const START_GOLD := 100
const START_HP := 100

var state: int = State.BUILD
var currency := START_GOLD
var base_hp := START_HP
var base_hp_max := START_HP
var wave_index := 0            # number of completed waves
var kills := 0
var towers_built := 0
var kill_counter := 0

# Run modifiers (rewards / relics)
var relics: Array[String] = []
var curses: Array[String] = []
var unlocked_towers: Array[String] = ["gatling"]
var type_bonus := {}           # id -> {damage, rate, range} multipliers
var global_damage := 1.0
var global_rate := 1.0
var slow_power := 1.0
var splash_bonus := 1.0
var cost_mult := 1.0
var ignore_armor := false
var enemy_speed_mult := 1.0    # curse: enemies move faster
var hp_drain_per_wave := 0     # curse: base HP lost at each wave end

var map: GameMap
var wave_mgr: WaveManager
var ui: GameUI
var enemies_node: Node2D
var towers_node: Node2D
var projectiles_node: Node2D
var overlay: DrawOverlay
var sfx: Sfx

var map_index := 0

var placing_type := ""
var selected_tower: Tower = null
var game_speed := 1.0
var _ghost_cell := Vector2i(-99, -99)
var _all_spawned := false
var _current_cards: Array = []
var _endless := false
var _smoke := false
var _smoke_timer := 0.0
var _hit_stop_active := false
var _cores_awarded := false
var last_core_gain := 0
var _meta_bounty_mult := 1.0   # set once by _apply_meta_upgrades

func _ready() -> void:
	_smoke = OS.get_environment("TD_SMOKE") == "1"
	for id in GameData.TOWERS.keys():
		type_bonus[id] = {damage = 1.0, rate = 1.0, range = 1.0}

	# Skip persistent upgrades in automated runs so smoke tests stay
	# deterministic regardless of the local save file.
	if not _smoke and OS.get_environment("TD_SHOT") == "":
		Meta.load_data()
		_apply_meta_upgrades()

	map_index = GameData.selected_map_index
	map = GameMap.new()
	map.setup(map_index)
	add_child(map)

	enemies_node = Node2D.new()
	add_child(enemies_node)
	towers_node = Node2D.new()
	add_child(towers_node)
	projectiles_node = Node2D.new()
	add_child(projectiles_node)

	overlay = DrawOverlay.new()
	overlay.game = self
	overlay.z_index = 30
	add_child(overlay)

	sfx = get_node("/root/GameSfx")
	_apply_saved_settings()
	sfx.play_map_music(GameData.map_by_index(map_index).id)

	wave_mgr = WaveManager.new()
	wave_mgr.spawn_enemy.connect(_on_spawn_enemy)
	wave_mgr.all_spawned.connect(func() -> void: _all_spawned = true)
	add_child(wave_mgr)

	ui = GameUI.new()
	add_child(ui)
	ui.setup(self)
	ui.tower_selected.connect(_on_tower_selected)
	ui.start_wave_pressed.connect(start_wave)
	ui.reward_chosen.connect(_on_reward_chosen)
	ui.restart_pressed.connect(func() -> void: get_tree().reload_current_scene())
	ui.continue_pressed.connect(_on_continue_endless)
	ui.menu_pressed.connect(_on_return_menu)
	ui.map_select_pressed.connect(_on_return_map_select)
	ui.upgrades_pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://scenes/Upgrades.tscn"))
	ui.sell_pressed.connect(sell_selected)
	ui.refresh()

	if _smoke:
		_smoke_setup()
	if OS.get_environment("TD_SHOT") != "" and OS.get_environment("TD_SHOT_MODE") == "reward":
		wave_index = 6
		unlocked_towers = ["gatling", "cannon"]
		state = State.REWARD
		_current_cards = _generate_cards()
		ui.show_rewards(_current_cards)
		var rt := get_tree().create_timer(1.0)
		rt.timeout.connect(_smoke_screenshot)
	elif OS.get_environment("TD_SHOT") != "":
		for cell in [Vector2i(7, 3), Vector2i(8, 3)]:
			place_tower("gatling", cell)
		place_tower("cannon", Vector2i(10, 6))
		place_tower("frost", Vector2i(5, 6))
		place_tower("sniper", Vector2i(13, 3))
		unlocked_towers = ["gatling", "cannon", "frost", "sniper"]
		wave_index = 3
		start_wave()
		_select_at(Vector2i(7, 3))
		placing_type = "cannon"
		_ghost_cell = Vector2i(9, 6)
		overlay.queue_redraw()
		var t := get_tree().create_timer(4.0)
		t.timeout.connect(_smoke_screenshot)

## ---------- Meta progression ----------
## Applied once at run start; levels come from the persistent Upgrades menu.
func _apply_meta_upgrades() -> void:
	_meta_bounty_mult = 1.0 + Meta.total("bounty")
	currency += int(Meta.total("start_gold"))
	base_hp_max += int(Meta.total("base_hp"))
	base_hp = base_hp_max
	global_damage *= 1.0 + Meta.total("damage")
	global_rate *= 1.0 + Meta.total("rate")
	for tid in ["cannon", "frost", "sniper"]:
		if Meta.level("unlock_" + tid) > 0 and not (tid in unlocked_towers):
			unlocked_towers.append(tid)
	if Meta.level("start_relic") > 0:
		var pool: Array[String] = []
		for rid in GameData.RELICS.keys():
			if not (rid in relics):
				pool.append(rid)
		if pool.size() > 0:
			_apply_reward({kind = "relic", id = pool[randi() % pool.size()]})

## Scales tower damage during endless mode so power keeps pace with difficulty.
func meta_endless_mult() -> float:
	if wave_index <= GameData.WIN_WAVE:
		return 1.0
	return 1.0 + 0.015 * float(wave_index - GameData.WIN_WAVE)

## Award cores once per run (victory, defeat, or quit-to-menu after playing).
func _finalize_run_cores(victory: bool) -> void:
	if _cores_awarded or _smoke:
		return
	last_core_gain = Meta.calc_cores(wave_index, kills, victory)
	if last_core_gain > 0:
		Meta.award(last_core_gain)
	_cores_awarded = true

func enemies_remaining() -> int:
	return enemies_node.get_child_count() + wave_mgr.pending_count()

func tower_cost(id: String) -> int:
	return ceili(GameData.TOWERS[id].cost * cost_mult)

## ---------- Wave flow ----------
func start_wave() -> void:
	if state != State.BUILD:
		return
	state = State.WAVE
	wave_index += 1
	_all_spawned = false
	sfx.play("wave_start")
	wave_mgr.start_wave(wave_index, map_index)
	ui.refresh()

func _physics_process(delta: float) -> void:
	if state == State.WAVE:
		ui.refresh()
		if _all_spawned and enemies_node.get_child_count() == 0:
			_on_wave_cleared()
	if _smoke:
		_smoke_tick(delta)

func _on_wave_cleared() -> void:
	# Wave-end relic income
	if "bonds" in relics:
		currency += 5
	if "medic" in relics:
		base_hp = mini(base_hp + 10, base_hp_max)
	if "interest" in relics:
		currency += mini(50, int(currency * 0.10))
	# Curse upkeep. Drain never finishes the base off on its own: losing
	# the run to an off-screen tick would feel unfair.
	if hp_drain_per_wave > 0:
		base_hp = maxi(1, base_hp - hp_drain_per_wave)

	if wave_index >= GameData.WIN_WAVE and not _endless:
		state = State.VICTORY
		sfx.play("victory")
		SaveData.mark_map_completed(map_index)
		_finalize_run_cores(true)
		ui.refresh()
		ui.show_end(true)
		return

	state = State.REWARD
	_current_cards = _generate_cards()
	ui.refresh()
	ui.show_rewards(_current_cards)

func _on_spawn_enemy(type_id: String, wave: int, spawn_idx: int) -> void:
	var e := Enemy.new()
	enemies_node.add_child(e)
	e.setup(type_id, wave, map.waypoints_for_spawn(spawn_idx), map_index, self)
	e.speed *= enemy_speed_mult
	e.died.connect(_on_enemy_died)
	e.leaked.connect(_on_enemy_leaked)
	e.split_spawn.connect(_on_enemy_split)

func _on_enemy_split(_e: Enemy, child_type: String, wave: int, path: PackedVector2Array, pos: Vector2, hp_mult: float) -> void:
	var child := Enemy.new()
	enemies_node.add_child(child)
	child.setup_split(child_type, wave, path, pos + Vector2(randf_range(-12, 12), randf_range(-8, 8)), hp_mult, map_index, self)
	child.speed *= enemy_speed_mult
	child.died.connect(_on_enemy_died)
	child.leaked.connect(_on_enemy_leaked)
	child.split_spawn.connect(_on_enemy_split)

func _on_enemy_died(e: Enemy) -> void:
	kills += 1
	kill_counter += 1
	sfx.play("enemy_die")
	var gain := int(round(e.bounty * _meta_bounty_mult))
	if "lucky" in relics and randf() < 0.10:
		gain += 5
		spawn_coin(e.global_position)
		sfx.play("coin")
	if "bounty5" in relics and kill_counter % 5 == 0:
		gain += 10
	currency += gain
	# Heavy enemies (tank, shield, healer) get extra punch: bigger flash,
	# screen shake, and a brief hit-stop. Judged on base bounty so wave
	# scaling doesn't promote everything to a "big kill".
	if GameData.ENEMIES[e.type_id].bounty >= 14:
		spawn_flash(e.global_position, 1.6)
		shake_screen(8.0)
		hit_stop()
	else:
		spawn_flash(e.global_position, 0.9)
	ui.refresh()

func _on_enemy_leaked(_e: Enemy, damage: int) -> void:
	base_hp -= damage
	sfx.play("leak")
	shake_screen()
	ui.refresh()
	if base_hp <= 0:
		base_hp = 0
		state = State.GAME_OVER
		sfx.play("defeat")
		_finalize_run_cores(false)
		_clear_field()
		ui.refresh()
		ui.show_end(false)

func _clear_field() -> void:
	wave_mgr.active = false
	for n in enemies_node.get_children():
		n.queue_free()
	for n in projectiles_node.get_children():
		n.queue_free()

func _on_continue_endless() -> void:
	_endless = true
	ui.hide_end()
	state = State.BUILD
	ui.refresh()

func _on_return_menu() -> void:
	if wave_index > 0 and not _cores_awarded:
		_finalize_run_cores(false)
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")

func _on_return_map_select() -> void:
	get_tree().change_scene_to_file("res://scenes/MapSelect.tscn")

func _apply_saved_settings() -> void:
	SaveData.apply_to_sfx(sfx)

## ---------- Reward layer ----------
func _generate_cards() -> Array:
	var pool: Array = []
	var early := wave_index < 5

	for id in GameData.TOWERS.keys():
		if not (id in unlocked_towers):
			var d: Dictionary = GameData.TOWERS[id]
			pool.append({w = 3 if early else 1, card = {
				kind = "tower", id = id,
				title = "New Tower: %s" % d.name,
				desc = "%s Unlocks for purchase." % d.desc}})

	for id in unlocked_towers:
		var d: Dictionary = GameData.TOWERS[id]
		for stat in GameData.UPGRADE_KINDS.keys():
			var u: Dictionary = GameData.UPGRADE_KINDS[stat]
			pool.append({w = 1 if early else 2, card = {
				kind = "upgrade", id = id, stat = stat,
				title = "%s +%d%% %s" % [d.name, int(u.amount * 100), u.label],
				desc = "All %s towers, current and future." % d.name}})

	for id in GameData.RELICS.keys():
		if not (id in relics):
			var r: Dictionary = GameData.RELICS[id]
			pool.append({w = 1 if early else 2, card = {
				kind = "relic", id = id, title = r.title, desc = r.desc}})

	# Curses stay out of the first waves so the downside is a real choice,
	# not a trap before the player has an economy going.
	if not early:
		for id in GameData.CURSES.keys():
			if not (id in curses):
				var c: Dictionary = GameData.CURSES[id]
				pool.append({w = 2, card = {
					kind = "curse", id = id, title = c.title, desc = c.desc}})

	# Weighted draw of 3 distinct cards; pad with gold if pool runs dry.
	# At most one curse per hand so there is always a safe pick.
	var cards: Array = []
	while cards.size() < 3:
		if pool.is_empty():
			cards.append({kind = "gold", amount = 75,
				title = "War Chest", desc = "+75 gold."})
			continue
		var total := 0
		for p in pool:
			total += p.w
		var roll := randi_range(1, total)
		for i in range(pool.size()):
			roll -= pool[i].w
			if roll <= 0:
				cards.append(pool[i].card)
				pool.remove_at(i)
				if cards[-1].kind == "curse":
					pool = pool.filter(func(p2: Dictionary) -> bool:
						return p2.card.kind != "curse")
				break
	return cards

func _on_reward_chosen(index: int) -> void:
	if state != State.REWARD or index >= _current_cards.size():
		return
	sfx.play("card")
	_apply_reward(_current_cards[index])
	if selected_tower != null and is_instance_valid(selected_tower):
		ui.show_tower_panel(selected_tower)
	ui.hide_rewards()
	state = State.BUILD
	ui.refresh()

func _apply_reward(card: Dictionary) -> void:
	match card.kind:
		"tower":
			unlocked_towers.append(card.id)
		"upgrade":
			var b: Dictionary = type_bonus[card.id]
			var amt: float = GameData.UPGRADE_KINDS[card.stat].amount
			b[card.stat] = b[card.stat] * (1.0 + amt)
		"gold":
			currency += card.amount
		"relic":
			relics.append(card.id)
			match card.id:
				"cryo": slow_power = 1.25
				"blast": splash_bonus = 1.3
				"scrap": cost_mult = 0.85
				"overcharge": global_damage *= 1.10
				"swift": global_rate *= 1.10
				"bunker":
					base_hp_max += 50
					base_hp = mini(base_hp + 50, base_hp_max)
				"bonds": currency += 40
				"ap": ignore_armor = true
		"curse":
			curses.append(card.id)
			match card.id:
				"glass_cannon":
					global_damage *= 1.40
					_scale_max_hp(0.80)
				"overclock":
					global_rate *= 1.30
					enemy_speed_mult *= 1.15
				"blood_money":
					currency += 150
					hp_drain_per_wave += 3
				"brittle":
					cost_mult *= 0.75
					_scale_max_hp(0.75)

## Curse HP cuts scale the cap and clamp current HP, but never kill outright.
func _scale_max_hp(mult: float) -> void:
	base_hp_max = maxi(1, int(base_hp_max * mult))
	base_hp = clampi(base_hp, 1, base_hp_max)

## ---------- Tower placement ----------
func _on_tower_selected(id: String) -> void:
	if not (id in unlocked_towers):
		return
	if currency < tower_cost(id):
		return
	placing_type = id
	sfx.play("ui_click")
	overlay.queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1, KEY_2, KEY_3, KEY_4:
				var ids: Array = GameData.TOWERS.keys()
				_on_tower_selected(ids[event.keycode - KEY_1])
			KEY_SPACE:
				start_wave()
			KEY_ESCAPE:
				_cancel_placement()
				_deselect()
			KEY_M:
				sfx.set_muted(not sfx.muted)
				SaveData.sync_from_sfx(sfx)
				ui.refresh()
		return
	if event is InputEventMouseMotion:
		if placing_type != "":
			_ghost_cell = GameMap.pos_to_cell(get_global_mouse_position())
			overlay.queue_redraw()
	elif event is InputEventMouseButton and event.pressed:
		var cell := GameMap.pos_to_cell(get_global_mouse_position())
		if event.button_index == MOUSE_BUTTON_LEFT:
			if placing_type != "":
				_try_place(cell)
			else:
				_select_at(cell)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_placement()
			_deselect()

func _select_at(cell: Vector2i) -> void:
	var t: Node = map.tower_at(cell) if map.in_grid(cell) else null
	if t is Tower:
		selected_tower = t
		ui.show_tower_panel(t)
	else:
		_deselect()
	overlay.queue_redraw()

func _deselect() -> void:
	if selected_tower != null:
		selected_tower = null
		ui.hide_tower_panel()
		overlay.queue_redraw()

func sell_selected() -> void:
	if selected_tower == null:
		return
	var refund := int(tower_cost(selected_tower.type_id) * 0.7)
	currency += refund
	sfx.play("sell")
	map.release(selected_tower.cell)
	selected_tower.queue_free()
	_deselect()
	ui.refresh()

func set_game_speed(speed: float) -> void:
	game_speed = speed
	if not _smoke:
		Engine.time_scale = speed

func _cancel_placement() -> void:
	placing_type = ""
	overlay.queue_redraw()
	ui.refresh()

func _try_place(cell: Vector2i) -> void:
	if not map.is_buildable(cell):
		return
	var cost := tower_cost(placing_type)
	if currency < cost:
		_cancel_placement()
		return
	currency -= cost
	place_tower(placing_type, cell)
	# Keep placing if still affordable, matching common TD flow.
	if currency < tower_cost(placing_type):
		placing_type = ""
	overlay.queue_redraw()
	ui.refresh()

func place_tower(id: String, cell: Vector2i) -> void:
	var t := Tower.new()
	towers_node.add_child(t)
	t.setup(id, self)
	t.cell = cell
	t.position = GameMap.cell_center(cell)
	map.occupy(cell, t)
	towers_built += 1
	spawn_place_burst(t.position)
	sfx.play("place")


## ---------- Effects ----------
func spawn_blocked_text(at: Vector2) -> void:
	var l := Label.new()
	l.text = "BLOCK"
	l.position = at + Vector2(-18, -28)
	l.z_index = 20
	l.add_theme_font_size_override("font_size", 13)
	l.add_theme_color_override("font_color", Color(0.55, 0.85, 1.0))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 3)
	add_child(l)
	var tw := create_tween()
	tw.tween_property(l, "position:y", l.position.y - 20.0, 0.45)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.45)
	tw.tween_callback(l.queue_free)

func spawn_flash(at: Vector2, size: float) -> void:
	var s := Sprite2D.new()
	s.texture = load("res://assets/sprites/flash.png")
	s.position = at
	s.scale = Vector2.ONE * size
	s.z_index = 15
	add_child(s)
	var tw := create_tween()
	tw.tween_property(s, "modulate:a", 0.0, 0.25)
	tw.parallel().tween_property(s, "scale", s.scale * 1.6, 0.25)
	tw.tween_callback(s.queue_free)

func spawn_coin(at: Vector2) -> void:
	var s := Sprite2D.new()
	s.texture = load("res://assets/sprites/coin.png")
	s.position = at
	s.z_index = 15
	add_child(s)
	var tw := create_tween()
	tw.tween_property(s, "position:y", at.y - 30.0, 0.5)
	tw.parallel().tween_property(s, "modulate:a", 0.0, 0.5)
	tw.tween_callback(s.queue_free)

func spawn_damage_number(at: Vector2, amount: float) -> void:
	if amount <= 0.0:
		return
	var l := Label.new()
	l.text = str(int(round(amount)))
	l.position = at + Vector2(randf_range(-10, 10), -20)
	l.z_index = 20
	var big := amount >= 30.0
	l.add_theme_font_size_override("font_size", 16 if big else 12)
	l.add_theme_color_override("font_color", Color(1, 0.85, 0.3) if big else Color(1, 1, 1, 0.9))
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 3)
	add_child(l)
	var tw := create_tween()
	tw.tween_property(l, "position:y", l.position.y - 26.0, 0.55)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.55)
	tw.tween_callback(l.queue_free)

func shake_screen(magnitude := 5.0) -> void:
	var tw := create_tween()
	for i in range(4):
		tw.tween_property(self, "position",
			Vector2(randf_range(-magnitude, magnitude), randf_range(-magnitude, magnitude)), 0.04)
	tw.tween_property(self, "position", Vector2.ZERO, 0.05)

## Freeze time for a beat. Timer runs on real time so it always recovers,
## restoring whatever speed the player had selected.
func hit_stop(duration := 0.08) -> void:
	if _smoke or _hit_stop_active:
		return
	_hit_stop_active = true
	Engine.time_scale = 0.05
	var t := get_tree().create_timer(duration, true, false, true)
	t.timeout.connect(_end_hit_stop)

func _end_hit_stop() -> void:
	_hit_stop_active = false
	Engine.time_scale = game_speed

## Bound-method timer callbacks are dropped if this node is freed first,
## so reset time scale on exit. Also covers leaving to the menu at 2x/3x.
func _exit_tree() -> void:
	Engine.time_scale = 1.0

func spawn_place_burst(at: Vector2) -> void:
	var p := CPUParticles2D.new()
	p.position = at
	p.amount = 14
	p.one_shot = true
	p.explosiveness = 1.0
	p.lifetime = 0.45
	p.direction = Vector2.UP
	p.spread = 180.0
	p.gravity = Vector2(0, 260)
	p.initial_velocity_min = 60.0
	p.initial_velocity_max = 150.0
	p.scale_amount_min = 1.5
	p.scale_amount_max = 3.0
	p.color = Color(1.0, 0.95, 0.6)
	p.z_index = 14
	p.emitting = true
	add_child(p)
	get_tree().create_timer(1.2).timeout.connect(p.queue_free)

## ---------- Headless smoke test (TD_SMOKE=1) ----------
func _smoke_setup() -> void:
	Engine.time_scale = 20.0
	currency = 2000
	if OS.get_environment("TD_SMOKE_TANKY") == "1":
		base_hp_max = 100000
		base_hp = base_hp_max
	for cell in [Vector2i(7, 3), Vector2i(8, 3), Vector2i(10, 6), Vector2i(5, 6), Vector2i(13, 3), Vector2i(13, 6)]:
		place_tower("gatling", cell)
	print("[smoke] placed towers, starting waves")

func _smoke_tick(delta: float) -> void:
	_smoke_timer += delta
	match state:
		State.BUILD:
			if wave_index == 2 and towers_node.get_child_count() >= 6:
				var before := currency
				_select_at(Vector2i(13, 6))
				sell_selected()
				print("[smoke] sold tower: gold %d -> %d, occupied=%d" % [before, currency, map.occupied.size()])
				place_tower("gatling", Vector2i(13, 6))
			print("[smoke] starting wave %d (gold=%d hp=%d kills=%d)" % [wave_index + 1, currency, base_hp, kills])
			start_wave()
		State.REWARD:
			print("[smoke] wave %d cleared, picking card: %s" % [wave_index, _current_cards[0].title])
			_on_reward_chosen(0)
		State.GAME_OVER:
			print("[smoke] GAME OVER at wave %d, kills=%d" % [wave_index, kills])
			get_tree().quit()
		State.VICTORY:
			print("[smoke] VICTORY, kills=%d" % kills)
			get_tree().quit()

## Screenshot helper for automated visual checks (TD_SHOT=path).
func _smoke_screenshot() -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(OS.get_environment("TD_SHOT"))
	print("[shot] saved")
	get_tree().quit()
