extends Control
## Main menu: start game, settings, upgrades, quit, and social links.

func _ready() -> void:
	SaveData.apply_to_sfx(get_node("/root/GameSfx"))
	get_node("/root/GameSfx").play_music(Sfx.MUSIC_MENU)
	Meta.load_data()
	_build_ui()

func _build_ui() -> void:
	MenuTheme.apply_bg(self)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 16)
	col.custom_minimum_size = Vector2(360, 0)
	center.add_child(col)

	var title := Label.new()
	title.text = "TD Roguelike"
	MenuTheme.style_title(title, 52)
	col.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Tower defense with roguelike rewards"
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.modulate = MenuTheme.TEXT_DIM
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(subtitle)

	var cores := Label.new()
	cores.text = "Cores: %d" % Meta.cores
	cores.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cores.modulate = Color(0.55, 0.9, 1.0)
	col.add_child(cores)

	col.add_child(_spacer(8))
	col.add_child(_menu_button("Start Game", _on_start))
	col.add_child(_menu_button("Upgrades", _on_upgrades))
	col.add_child(_menu_button("Settings", _on_settings))
	if not OS.has_feature("web"):
		col.add_child(_menu_button("Quit Game", _on_quit))

	col.add_child(_spacer(20))
	var social := HBoxContainer.new()
	social.alignment = BoxContainer.ALIGNMENT_CENTER
	social.add_theme_constant_override("separation", 16)
	col.add_child(social)

	var li := SocialIconButton.new()
	li.setup(SocialIconButton.Kind.LINKEDIN, "LinkedIn", _open_linkedin)
	social.add_child(li)

	var gh := SocialIconButton.new()
	gh.setup(SocialIconButton.Kind.GITHUB, "GitHub", _open_github)
	social.add_child(gh)

func _menu_button(text: String, callback: Callable) -> Button:
	var b := Button.new()
	b.text = text
	MenuTheme.style_button(b)
	b.pressed.connect(func() -> void:
		get_node("/root/GameSfx").play("ui_click")
		callback.call())
	return b

func _spacer(h: int) -> Control:
	var s := Control.new()
	s.custom_minimum_size = Vector2(0, h)
	return s

func _on_start() -> void:
	get_tree().change_scene_to_file("res://scenes/MapSelect.tscn")

func _on_upgrades() -> void:
	get_tree().change_scene_to_file("res://scenes/Upgrades.tscn")

func _on_settings() -> void:
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")

func _on_quit() -> void:
	get_tree().quit()

func _open_linkedin() -> void:
	_open_url("https://linkedin.com/in/nicolasc-ux/")

func _open_github() -> void:
	_open_url("https://github.com/NicolasCandelaria")

func _open_url(url: String) -> void:
	get_node("/root/GameSfx").play("ui_click")
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.open('%s', '_blank')" % url)
	else:
		OS.shell_open(url)
