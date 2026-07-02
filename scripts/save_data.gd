class_name SaveData
extends RefCounted
## Persists map unlock progress, completion flags, and user settings.

const PROGRESS_PATH := "user://progress.cfg"
const SETTINGS_PATH := "user://settings.cfg"
const MAP_COUNT := 6

static func load_progress() -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(PROGRESS_PATH) != OK:
		return {unlocked_maps = 1, completed = []}
	var completed: Array = []
	var raw: Variant = cfg.get_value("progress", "completed", [])
	if raw is Array:
		for v in raw:
			completed.append(int(v))
	return {
		unlocked_maps = int(cfg.get_value("progress", "unlocked_maps", 1)),
		completed = completed,
	}

static func save_progress(unlocked_maps: int, completed: Array = []) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "unlocked_maps", clampi(unlocked_maps, 1, MAP_COUNT))
	cfg.set_value("progress", "completed", completed)
	cfg.save(PROGRESS_PATH)

static func mark_map_completed(completed_index: int) -> void:
	var p := load_progress()
	var completed: Array = p.completed.duplicate()
	if not (completed_index in completed):
		completed.append(completed_index)
	var next_unlocked := maxi(p.unlocked_maps, completed_index + 2)
	save_progress(next_unlocked, completed)

static func is_map_unlocked(map_index: int) -> bool:
	return map_index < load_progress().unlocked_maps

static func is_map_completed(map_index: int) -> bool:
	return map_index in load_progress().completed

static func default_settings() -> Dictionary:
	return {
		sfx_volume = 1.0,
		music_volume = 0.6,
		muted = false,
		fullscreen = false,
	}

static func load_settings() -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return default_settings()
	var d := default_settings()
	d.sfx_volume = float(cfg.get_value("settings", "sfx_volume", d.sfx_volume))
	d.music_volume = float(cfg.get_value("settings", "music_volume", d.music_volume))
	d.muted = bool(cfg.get_value("settings", "muted", d.muted))
	d.fullscreen = bool(cfg.get_value("settings", "fullscreen", d.fullscreen))
	return d

static func save_settings(settings: Dictionary) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("settings", "sfx_volume", clampf(settings.sfx_volume, 0.0, 1.0))
	cfg.set_value("settings", "music_volume", clampf(settings.music_volume, 0.0, 1.0))
	cfg.set_value("settings", "muted", settings.muted)
	cfg.set_value("settings", "fullscreen", settings.fullscreen)
	cfg.save(SETTINGS_PATH)

static func apply_window_mode(fullscreen: bool) -> void:
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

static func apply_to_sfx(sfx_node: Sfx) -> void:
	var s := load_settings()
	sfx_node.set_sfx_volume(s.sfx_volume)
	sfx_node.set_music_volume(s.music_volume)
	sfx_node.set_muted(s.muted)
	apply_window_mode(s.fullscreen)

static func sync_from_sfx(sfx_node: Sfx) -> void:
	var s := load_settings()
	s.sfx_volume = sfx_node.sfx_volume
	s.music_volume = sfx_node.music_volume
	s.muted = sfx_node.muted
	save_settings(s)
