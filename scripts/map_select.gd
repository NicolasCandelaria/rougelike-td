extends Control
## Map selection screen with sequential unlock progress.

func _ready() -> void:
	SaveData.apply_to_sfx(get_node("/root/GameSfx"))
	_build_ui()

func _build_ui() -> void:
	MenuTheme.apply_bg(self)

	var root := MarginContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 40)
	root.add_theme_constant_override("margin_right", 40)
	root.add_theme_constant_override("margin_top", 30)
	root.add_theme_constant_override("margin_bottom", 30)
	add_child(root)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	root.add_child(col)

	var header := HBoxContainer.new()
	col.add_child(header)

	var title := Label.new()
	title.text = "Select Map"
	title.add_theme_font_size_override("font_size", 36)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var back := Button.new()
	back.text = "Back"
	back.custom_minimum_size = Vector2(100, 40)
	back.pressed.connect(func() -> void:
		get_node("/root/GameSfx").play("ui_click")
		get_tree().change_scene_to_file("res://scenes/Menu.tscn"))
	header.add_child(back)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 520)
	col.add_child(scroll)

	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 12)
	list.custom_minimum_size = Vector2(1180, 0)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)

	var progress := SaveData.load_progress()
	var unlocked: int = progress.unlocked_maps
	for i in range(GameData.map_count()):
		var m: Dictionary = GameData.map_by_index(i)
		list.add_child(_map_row(i, m, i < unlocked, SaveData.is_map_completed(i)))

func _map_row(index: int, data: Dictionary, is_unlocked: bool, is_completed: bool) -> PanelContainer:
	var panel := MenuTheme.make_panel()
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	panel.add_child(row)

	var badge := Label.new()
	badge.custom_minimum_size = Vector2(36, 0)
	if is_completed:
		badge.text = "OK"
		badge.modulate = Color(0.45, 1.0, 0.55)
	elif not is_unlocked:
		badge.text = "--"
		badge.modulate = Color(1, 0.5, 0.5)
	else:
		badge.text = ">>"
	badge.add_theme_font_size_override("font_size", 20)
	row.add_child(badge)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)

	var name := Label.new()
	name.text = "%d. %s" % [index + 1, data.name]
	name.add_theme_font_size_override("font_size", 22)
	info.add_child(name)

	var desc := Label.new()
	desc.text = data.desc if is_unlocked else "Complete the previous map to unlock."
	desc.add_theme_font_size_override("font_size", 14)
	desc.modulate = MenuTheme.TEXT_DIM
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(desc)

	if is_unlocked:
		var meta := Label.new()
		var paths: int = data.paths.size()
		meta.text = "20 waves  |  %d entrance%s  |  HP x%.0f%%" % [
			paths, "s" if paths != 1 else "", data.hp_scale * 100.0]
		meta.add_theme_font_size_override("font_size", 13)
		meta.modulate = Color(0.75, 0.9, 1.0)
		info.add_child(meta)

		var play := Button.new()
		play.text = "Replay" if is_completed else "Play"
		play.custom_minimum_size = Vector2(100, 48)
		var idx := index
		play.pressed.connect(func() -> void:
			get_node("/root/GameSfx").play("ui_click")
			GameData.selected_map_index = idx
			get_tree().change_scene_to_file("res://scenes/Main.tscn"))
		row.add_child(play)
	else:
		var lock := Label.new()
		lock.text = "LOCKED"
		lock.add_theme_font_size_override("font_size", 18)
		lock.modulate = Color(1, 0.5, 0.5)
		row.add_child(lock)

	return panel
