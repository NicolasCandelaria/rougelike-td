class_name GameUI
extends CanvasLayer

signal tower_selected(id: String)
signal start_wave_pressed
signal reward_chosen(index: int)
signal restart_pressed
signal continue_pressed
signal sell_pressed
signal menu_pressed
signal map_select_pressed
signal upgrades_pressed

var game: Node

var _wave_label: Label
var _map_label: Label
var _enemy_label: Label
var _gold_label: Label
var _hp_bar: ProgressBar
var _hp_label: Label
var _tower_buttons := {}
var _start_button: Button
var _hint_label: Label
var _reward_overlay: Control
var _end_overlay: Control
var _relic_label: Label
var _preview_label: Label
var _speed_button: Button
var _mute_button: Button
var _tower_panel: PanelContainer
var _tower_panel_label: Label
var _sound_menu: PanelContainer

const BAR_Y := 640.0
const BAR_H := 80.0

func setup(game_ref: Node) -> void:
	game = game_ref
	_build_hud()
	_build_bottom_bar()

func _build_hud() -> void:
	var top := PanelContainer.new()
	top.position = Vector2(8, 8)
	top.self_modulate = Color(1, 1, 1, 0.85)
	add_child(top)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	top.add_child(row)

	_map_label = _mk_label(row, "")
	_wave_label = _mk_label(row, "Wave 0 / %d" % GameData.WIN_WAVE)
	_enemy_label = _mk_label(row, "Enemies: 0")
	_gold_label = _mk_label(row, "Gold: 0")

	var hp_box := HBoxContainer.new()
	hp_box.add_theme_constant_override("separation", 8)
	row.add_child(hp_box)
	_mk_label(hp_box, "Base")
	_hp_bar = ProgressBar.new()
	_hp_bar.custom_minimum_size = Vector2(160, 22)
	_hp_bar.show_percentage = false
	hp_box.add_child(_hp_bar)
	_hp_label = _mk_label(hp_box, "")

	_relic_label = Label.new()
	_relic_label.position = Vector2(8, 44)
	_relic_label.add_theme_font_size_override("font_size", 13)
	_relic_label.modulate = Color(1, 1, 0.75, 0.9)
	add_child(_relic_label)

	_build_tower_panel()

func _build_bottom_bar() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(0, BAR_Y)
	panel.custom_minimum_size = Vector2(1280, BAR_H)
	add_child(panel)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)

	for id in GameData.TOWERS.keys():
		var d: Dictionary = GameData.TOWERS[id]
		var b := Button.new()
		b.custom_minimum_size = Vector2(150, 64)
		b.icon = load(d.gun_tex)
		b.expand_icon = true
		b.tooltip_text = d.desc
		b.pressed.connect(func() -> void: tower_selected.emit(id))
		row.add_child(b)
		_tower_buttons[id] = b

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	# Hint lives above the bar, not inside it: the bar has no horizontal
	# room left once all buttons are visible.
	_hint_label = Label.new()
	_hint_label.position = Vector2(8, BAR_Y - 24)
	_hint_label.add_theme_font_size_override("font_size", 14)
	_hint_label.modulate = Color(1, 1, 1, 0.7)
	add_child(_hint_label)

	_preview_label = _mk_label(row, "")
	_preview_label.add_theme_font_size_override("font_size", 14)
	# Fixed width + clip so long previews can't push the right-side
	# buttons (speed / start) off the edge of the screen.
	_preview_label.clip_text = true
	_preview_label.custom_minimum_size = Vector2(220, 0)

	_mute_button = Button.new()
	_mute_button.text = "Snd"
	_mute_button.custom_minimum_size = Vector2(56, 64)
	_mute_button.tooltip_text = "Toggle sound (M)"
	_mute_button.pressed.connect(func() -> void:
		game.sfx.set_muted(not game.sfx.muted)
		SaveData.sync_from_sfx(game.sfx)
		refresh())
	row.add_child(_mute_button)

	var vol_button := Button.new()
	vol_button.text = "Vol"
	vol_button.custom_minimum_size = Vector2(56, 64)
	vol_button.tooltip_text = "Sound volume settings"
	vol_button.pressed.connect(_toggle_sound_menu)
	row.add_child(vol_button)

	_speed_button = Button.new()
	_speed_button.text = "1x"
	_speed_button.custom_minimum_size = Vector2(56, 64)
	_speed_button.tooltip_text = "Game speed"
	_speed_button.pressed.connect(_cycle_speed)
	row.add_child(_speed_button)

	# Reserve room at the end of the row for the anchored start button below.
	var start_gap := Control.new()
	start_gap.custom_minimum_size = Vector2(178, 0)
	row.add_child(start_gap)

	# The start button is anchored to the bottom-right corner of the screen
	# (not inside the row) so it can never be pushed off-screen by the
	# other bar contents.
	_start_button = Button.new()
	_start_button.text = "Start Wave"
	_start_button.custom_minimum_size = Vector2(170, 64)
	_start_button.position = Vector2(1280 - 178, BAR_Y + 8)
	_start_button.tooltip_text = "Hotkey: Space"
	_start_button.pressed.connect(func() -> void: start_wave_pressed.emit())
	add_child(_start_button)

func _mk_label(parent: Node, text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 18)
	parent.add_child(l)
	return l

func _cycle_speed() -> void:
	game.sfx.play("ui_click")
	var next: float = {1.0: 2.0, 2.0: 4.0, 4.0: 1.0}[game.game_speed]
	game.set_game_speed(next)
	_speed_button.text = "%dx" % int(next)

func _build_tower_panel() -> void:
	_tower_panel = PanelContainer.new()
	_tower_panel.position = Vector2(1020, 44)
	_tower_panel.visible = false
	add_child(_tower_panel)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	_tower_panel.add_child(col)
	_tower_panel_label = Label.new()
	_tower_panel_label.add_theme_font_size_override("font_size", 15)
	col.add_child(_tower_panel_label)
	var sell := Button.new()
	sell.text = "Sell (70% refund)"
	sell.pressed.connect(func() -> void: sell_pressed.emit())
	col.add_child(sell)

## ---------- Sound menu ----------
func _toggle_sound_menu() -> void:
	game.sfx.play("ui_click")
	if _sound_menu == null:
		_build_sound_menu()
	_sound_menu.visible = not _sound_menu.visible

func _build_sound_menu() -> void:
	_sound_menu = PanelContainer.new()
	_sound_menu.position = Vector2(940, 470)
	_sound_menu.custom_minimum_size = Vector2(300, 0)
	add_child(_sound_menu)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	_sound_menu.add_child(col)

	var title := Label.new()
	title.text = "Sound Volume"
	title.add_theme_font_size_override("font_size", 17)
	col.add_child(title)

	_mk_volume_row(col, "SFX", game.sfx.sfx_volume,
		func(v: float) -> void:
			game.sfx.set_sfx_volume(v)
			SaveData.sync_from_sfx(game.sfx)
			game.sfx.play("ui_click"))
	_mk_volume_row(col, "Music", game.sfx.music_volume,
		func(v: float) -> void:
			game.sfx.set_music_volume(v)
			SaveData.sync_from_sfx(game.sfx))

	var close := Button.new()
	close.text = "Close"
	close.pressed.connect(func() -> void: _sound_menu.visible = false)
	col.add_child(close)

func _mk_volume_row(parent: Node, label_text: String, initial: float, on_change: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)
	var l := Label.new()
	l.text = label_text
	l.custom_minimum_size = Vector2(52, 0)
	l.add_theme_font_size_override("font_size", 15)
	row.add_child(l)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = initial
	slider.custom_minimum_size = Vector2(180, 22)
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.value_changed.connect(on_change)
	row.add_child(slider)

func show_tower_panel(t: Tower) -> void:
	var d: Dictionary = GameData.TOWERS[t.type_id]
	_tower_panel_label.text = "%s\nDamage: %.0f\nFire rate: %.1f/s\nRange: %.0f" % [
		d.name, t.stat_damage(), t.stat_rate(), t.stat_range()]
	_tower_panel.visible = true

func hide_tower_panel() -> void:
	_tower_panel.visible = false

func _wave_preview_text(wave: int) -> String:
	var counts := {}
	for g in GameData.wave_groups(wave, game.map_index):
		counts[g.t] = counts.get(g.t, 0) + g.n
	var parts: Array[String] = []
	for t in counts.keys():
		parts.append("%d %s" % [counts[t], GameData.ENEMIES[t].name])
	return "Next: " + ", ".join(parts)

func refresh() -> void:
	var map_data: Dictionary = GameData.map_by_index(game.map_index)
	_map_label.text = map_data.name
	var next_wave: int = game.wave_index + 1
	if game.wave_index >= GameData.WIN_WAVE:
		_wave_label.text = "Wave %d (endless)" % game.wave_index
	else:
		_wave_label.text = "Wave %d / %d" % [game.wave_index, GameData.WIN_WAVE]
	_enemy_label.text = "Enemies: %d" % game.enemies_remaining()
	_gold_label.text = "Gold: %d" % game.currency
	_hp_bar.max_value = game.base_hp_max
	_hp_bar.value = game.base_hp
	_hp_label.text = "%d / %d" % [game.base_hp, game.base_hp_max]

	for id in _tower_buttons.keys():
		var b: Button = _tower_buttons[id]
		var unlocked: bool = id in game.unlocked_towers
		var cost: int = game.tower_cost(id)
		var d: Dictionary = GameData.TOWERS[id]
		if unlocked:
			b.text = "%s  $%d" % [d.name, cost]
			b.disabled = game.currency < cost
		else:
			b.text = "%s  [locked]" % d.name
			b.disabled = true

	_start_button.disabled = game.state != game.State.BUILD
	if game.state == game.State.WAVE:
		_start_button.text = "Wave running..."
		_preview_label.text = ""
	else:
		_start_button.text = "Start Wave %d" % next_wave
		_preview_label.text = _wave_preview_text(next_wave)
	_mute_button.text = "Mute" if game.sfx.muted else "Snd"
	var relic_parts: Array[String] = []
	if game.relics.size() > 0:
		relic_parts.append("Relics: " + ", ".join(game.relics.map(
			func(id: String) -> String: return GameData.RELICS[id].title)))
	if game.curses.size() > 0:
		relic_parts.append("Curses: " + ", ".join(game.curses.map(
			func(id: String) -> String: return GameData.CURSES[id].title)))
	_relic_label.text = "   ".join(relic_parts)
	_hint_label.text = "1-4 pick tower, click grass to place. Right-click cancels. Space starts." \
		if game.state == game.State.BUILD or game.placing_type != "" else ""

## ---------- Reward overlay ----------
## Per-kind card flavor: accent color drives the frame, tag, and title.
const CARD_STYLES := {
	tower = {tag = "TOWER", accent = Color(0.45, 0.75, 1.0), bg = Color(0.09, 0.13, 0.19)},
	upgrade = {tag = "UPGRADE", accent = Color(1.0, 0.65, 0.25), bg = Color(0.16, 0.12, 0.08)},
	relic = {tag = "RELIC", accent = Color(1.0, 0.85, 0.35), bg = Color(0.15, 0.13, 0.07)},
	gold = {tag = "GOLD", accent = Color(1.0, 0.9, 0.4), bg = Color(0.14, 0.12, 0.06)},
	curse = {tag = "CURSE", accent = Color(0.8, 0.4, 1.0), bg = Color(0.12, 0.06, 0.17)},
}

func _card_icon_path(card: Dictionary) -> String:
	match card.kind:
		"tower": return GameData.TOWERS[card.id].gun_tex
		"upgrade": return GameData.UPGRADE_KINDS[card.stat].icon
		"relic": return GameData.RELICS[card.id].icon
		"curse": return GameData.CURSES[card.id].icon
		"gold": return GameData.GOLD_ICON
	return ""

func _card_stylebox(bg: Color, accent: Color, border_alpha: float) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = Color(accent, border_alpha)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	sb.set_content_margin_all(12)
	return sb

func _make_reward_card(card: Dictionary, index: int) -> Button:
	var style: Dictionary = CARD_STYLES[card.kind]
	var accent: Color = style.accent
	var bg: Color = style.bg

	var b := Button.new()
	b.custom_minimum_size = Vector2(260, 250)
	b.add_theme_stylebox_override("normal", _card_stylebox(bg, accent, 0.55))
	b.add_theme_stylebox_override("hover", _card_stylebox(bg.lightened(0.06), accent, 1.0))
	b.add_theme_stylebox_override("pressed", _card_stylebox(bg.darkened(0.15), accent, 1.0))
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.pressed.connect(func() -> void: reward_chosen.emit(index))

	# Content lives in a mouse-transparent VBox so the whole card stays
	# one clickable button while allowing per-label colors and an icon.
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.set_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 12)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 8)
	b.add_child(col)

	var tag := Label.new()
	tag.text = style.tag
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.add_theme_font_size_override("font_size", 13)
	tag.add_theme_color_override("font_color", accent)
	col.add_child(tag)

	var icon_path := _card_icon_path(card)
	if icon_path != "":
		var icon := TextureRect.new()
		icon.texture = load(icon_path)
		icon.custom_minimum_size = Vector2(0, 72)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		col.add_child(icon)

	var title := Label.new()
	title.text = card.title
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", accent.lightened(0.35))
	col.add_child(title)

	var desc := Label.new()
	desc.text = card.desc
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 14)
	desc.add_theme_color_override("font_color", Color(1, 1, 1, 0.82))
	col.add_child(desc)
	return b

func show_rewards(cards: Array) -> void:
	_reward_overlay = _dim_overlay()
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_reward_overlay.add_child(center)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	center.add_child(col)

	var title := Label.new()
	title.text = "Wave %d cleared. Choose a reward:" % game.wave_index
	title.add_theme_font_size_override("font_size", 26)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	col.add_child(row)

	for i in range(cards.size()):
		row.add_child(_make_reward_card(cards[i], i))

func hide_rewards() -> void:
	if is_instance_valid(_reward_overlay):
		_reward_overlay.queue_free()
	_reward_overlay = null

## ---------- End screens ----------
func show_end(victory: bool) -> void:
	_end_overlay = _dim_overlay()
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_end_overlay.add_child(center)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	center.add_child(col)

	var title := Label.new()
	title.text = "VICTORY" if victory else "BASE DESTROYED"
	title.add_theme_font_size_override("font_size", 42)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)

	if victory:
		var map_name := Label.new()
		map_name.text = "%s cleared!" % GameData.map_by_index(game.map_index).name
		map_name.add_theme_font_size_override("font_size", 22)
		map_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(map_name)

	var stats := Label.new()
	stats.text = "Waves survived: %d\nKills: %d\nTowers built: %d" % [
		game.wave_index if not victory else GameData.WIN_WAVE, game.kills, game.towers_built]
	stats.add_theme_font_size_override("font_size", 20)
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(stats)

	var cores_lbl := Label.new()
	if game.last_core_gain > 0:
		cores_lbl.text = "+%d Cores earned  (total: %d)" % [game.last_core_gain, Meta.cores]
	else:
		cores_lbl.text = "Cores: %d" % Meta.cores
	cores_lbl.add_theme_font_size_override("font_size", 18)
	cores_lbl.modulate = Color(0.55, 0.9, 1.0)
	cores_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(cores_lbl)

	if victory:
		var cont := Button.new()
		cont.text = "Continue (endless)"
		cont.custom_minimum_size = Vector2(240, 50)
		cont.pressed.connect(func() -> void: continue_pressed.emit())
		col.add_child(cont)

		if game.map_index + 1 < GameData.map_count() and SaveData.is_map_unlocked(game.map_index + 1):
			var next_map := Button.new()
			next_map.text = "Next Map: %s" % GameData.map_by_index(game.map_index + 1).name
			next_map.custom_minimum_size = Vector2(240, 50)
			next_map.pressed.connect(func() -> void:
				GameData.selected_map_index = game.map_index + 1
				restart_pressed.emit())
			col.add_child(next_map)

	var upgrades_btn := Button.new()
	upgrades_btn.text = "Upgrades"
	upgrades_btn.custom_minimum_size = Vector2(240, 50)
	upgrades_btn.pressed.connect(func() -> void: upgrades_pressed.emit())
	col.add_child(upgrades_btn)

	var map_btn := Button.new()
	map_btn.text = "Map Select"
	map_btn.custom_minimum_size = Vector2(240, 50)
	map_btn.pressed.connect(func() -> void: map_select_pressed.emit())
	col.add_child(map_btn)

	var menu_btn := Button.new()
	menu_btn.text = "Main Menu"
	menu_btn.custom_minimum_size = Vector2(240, 50)
	menu_btn.pressed.connect(func() -> void: menu_pressed.emit())
	col.add_child(menu_btn)

	var restart := Button.new()
	restart.text = "New Run"
	restart.custom_minimum_size = Vector2(240, 50)
	restart.pressed.connect(func() -> void: restart_pressed.emit())
	col.add_child(restart)

func hide_end() -> void:
	if is_instance_valid(_end_overlay):
		_end_overlay.queue_free()
	_end_overlay = null

func _dim_overlay() -> Control:
	var c := Control.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.add_child(dim)
	add_child(c)
	return c
