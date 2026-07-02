extends Control
## Settings screen with persistent audio and display options.

var _settings: Dictionary
var _mute_check: CheckBox
var _fullscreen_check: CheckBox

func _ready() -> void:
	_settings = SaveData.load_settings()
	SaveData.apply_to_sfx(get_node("/root/GameSfx"))
	_build_ui()

func _build_ui() -> void:
	MenuTheme.apply_bg(self)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := MenuTheme.make_panel()
	panel.custom_minimum_size = Vector2(420, 0)
	center.add_child(panel)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 14)
	panel.add_child(col)

	var title := Label.new()
	title.text = "Settings"
	title.add_theme_font_size_override("font_size", 32)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)

	_mk_slider_row(col, "SFX Volume", _settings.sfx_volume, func(v: float) -> void:
		_settings.sfx_volume = v
		get_node("/root/GameSfx").set_sfx_volume(v)
		get_node("/root/GameSfx").play("ui_click"))
	_mk_slider_row(col, "Music Volume", _settings.music_volume, func(v: float) -> void:
		_settings.music_volume = v
		get_node("/root/GameSfx").set_music_volume(v))

	_mute_check = CheckBox.new()
	_mute_check.text = "Mute all sound"
	_mute_check.button_pressed = _settings.muted
	_mute_check.toggled.connect(func(on: bool) -> void:
		_settings.muted = on
		get_node("/root/GameSfx").set_muted(on))
	col.add_child(_mute_check)

	_fullscreen_check = CheckBox.new()
	_fullscreen_check.text = "Fullscreen"
	_fullscreen_check.button_pressed = _settings.fullscreen
	_fullscreen_check.toggled.connect(func(on: bool) -> void:
		_settings.fullscreen = on
		SaveData.apply_window_mode(on))
	col.add_child(_fullscreen_check)

	col.add_child(_spacer(8))

	var save := Button.new()
	save.text = "Save & Back"
	save.custom_minimum_size = Vector2(0, 48)
	save.pressed.connect(_save_and_back)
	col.add_child(save)

	var cancel := Button.new()
	cancel.text = "Back without saving"
	cancel.pressed.connect(func() -> void:
		get_node("/root/GameSfx").play("ui_click")
		SaveData.apply_to_sfx(get_node("/root/GameSfx"))
		get_tree().change_scene_to_file("res://scenes/Menu.tscn"))
	col.add_child(cancel)

func _mk_slider_row(parent: Node, label_text: String, initial: float, on_change: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)
	var l := Label.new()
	l.text = label_text
	l.custom_minimum_size = Vector2(120, 0)
	l.add_theme_font_size_override("font_size", 16)
	row.add_child(l)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = initial
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(on_change)
	row.add_child(slider)

func _spacer(h: int) -> Control:
	var s := Control.new()
	s.custom_minimum_size = Vector2(0, h)
	return s

func _save_and_back() -> void:
	get_node("/root/GameSfx").play("ui_click")
	SaveData.save_settings(_settings)
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
