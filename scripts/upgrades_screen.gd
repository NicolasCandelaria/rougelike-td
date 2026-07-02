extends Control
## Persistent meta upgrade shop. Cores are earned from run performance.

func _ready() -> void:
	SaveData.apply_to_sfx(get_node("/root/GameSfx"))
	Meta.load_data()
	_build_ui()

func _build_ui() -> void:
	MenuTheme.apply_bg(self)

	var root := MarginContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 36)
	root.add_theme_constant_override("margin_right", 36)
	root.add_theme_constant_override("margin_top", 28)
	root.add_theme_constant_override("margin_bottom", 28)
	add_child(root)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	root.add_child(col)

	var header := HBoxContainer.new()
	col.add_child(header)

	var title := Label.new()
	title.text = "Upgrades"
	title.add_theme_font_size_override("font_size", 36)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var cores_lbl := Label.new()
	cores_lbl.name = "CoresLabel"
	cores_lbl.text = "Cores: %d" % Meta.cores
	cores_lbl.add_theme_font_size_override("font_size", 22)
	cores_lbl.modulate = Color(0.55, 0.9, 1.0)
	header.add_child(cores_lbl)

	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(100, 40)
	back.pressed.connect(_go_menu)
	header.add_child(back)

	var hint := Label.new()
	hint.text = "Spend Cores on permanent bonuses. Earn Cores by clearing waves and winning maps."
	hint.modulate = MenuTheme.TEXT_DIM
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	col.add_child(hint)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 520)
	col.add_child(scroll)

	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 10)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)

	for id in Meta.UPGRADES.keys():
		list.add_child(_upgrade_row(id))

func _upgrade_row(id: String) -> PanelContainer:
	var d: Dictionary = Meta.UPGRADES[id]
	var panel := MenuTheme.make_panel()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	panel.add_child(row)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)

	var name := Label.new()
	var lv := Meta.level(id)
	name.text = "%s  (%d / %d)" % [d.name, lv, d.max]
	name.add_theme_font_size_override("font_size", 20)
	info.add_child(name)

	var desc := Label.new()
	desc.text = d.desc
	desc.modulate = MenuTheme.TEXT_DIM
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(desc)

	var buy := Button.new()
	buy.custom_minimum_size = Vector2(120, 44)
	if Meta.is_maxed(id):
		buy.text = "MAX"
		buy.disabled = true
	else:
		var cost := Meta.next_cost(id)
		buy.text = "Buy %d" % cost
		buy.disabled = not Meta.can_buy(id)
		buy.pressed.connect(func() -> void:
			if Meta.buy(id):
				get_node("/root/GameSfx").play("card")
				get_tree().reload_current_scene())
	row.add_child(buy)
	return panel

func _go_menu() -> void:
	get_node("/root/GameSfx").play("ui_click")
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
