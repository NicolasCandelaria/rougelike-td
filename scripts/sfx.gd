class_name Sfx
extends Node
## Pooled sound playback with per-sound volume, pitch jitter, and throttling.
## Throttle stops rapid-fire sources (six gatlings) from stacking into noise.
## Also owns the background music player (per-map loops + menu theme).

const SOUNDS := {
	"shoot_gatling": {path = "res://assets/audio/shoot_gatling.ogg", vol = -14.0, jitter = 0.12, throttle = 70},
	"shoot_cannon": {path = "res://assets/audio/shoot_cannon.ogg", vol = -8.0, jitter = 0.08, throttle = 120},
	"shoot_frost": {path = "res://assets/audio/shoot_frost.ogg", vol = -12.0, jitter = 0.10, throttle = 120},
	"shoot_sniper": {path = "res://assets/audio/shoot_sniper.ogg", vol = -9.0, jitter = 0.08, throttle = 120},
	"impact_splash": {path = "res://assets/audio/impact_splash.ogg", vol = -10.0, jitter = 0.10, throttle = 110},
	"enemy_die": {path = "res://assets/audio/enemy_die.ogg", vol = -12.0, jitter = 0.18, throttle = 60},
	"leak": {path = "res://assets/audio/leak.ogg", vol = -4.0, jitter = 0.0, throttle = 150},
	"place": {path = "res://assets/audio/place.ogg", vol = -6.0, jitter = 0.05, throttle = 0},
	"sell": {path = "res://assets/audio/sell.ogg", vol = -6.0, jitter = 0.0, throttle = 0},
	"ui_click": {path = "res://assets/audio/ui_click.ogg", vol = -6.0, jitter = 0.0, throttle = 40},
	"card": {path = "res://assets/audio/card.ogg", vol = -5.0, jitter = 0.0, throttle = 0},
	"wave_start": {path = "res://assets/audio/wave_start.ogg", vol = -5.0, jitter = 0.0, throttle = 0},
	"coin": {path = "res://assets/audio/coin.ogg", vol = -8.0, jitter = 0.15, throttle = 50},
	"victory": {path = "res://assets/audio/victory.mp3", vol = -4.0, jitter = 0.0, throttle = 0},
	"defeat": {path = "res://assets/audio/defeat.mp3", vol = -4.0, jitter = 0.0, throttle = 0},
}

const POOL_SIZE := 14

## Background music: one loop per map plus a dedicated menu theme.
## Tracks are CC0 loops from Kenney's Music Loops pack (kenney.nl).
const MUSIC_MENU := "res://assets/audio/music_menu.ogg"
const MUSIC_BY_MAP := {
	"meadow": "res://assets/audio/music_meadow.ogg",
	"canyon": "res://assets/audio/music_canyon.ogg",
	"crossroads": "res://assets/audio/music_crossroads.ogg",
	"fracture": "res://assets/audio/music_fracture.ogg",
	"siege": "res://assets/audio/music_siege.ogg",
	"citadel": "res://assets/audio/music_citadel.ogg",
}
const MUSIC_BASE_DB := -14.0   # keep music under the SFX

var muted := false
var sfx_volume := 1.0          # linear 0..1, user-set via the sound menu
var music_volume := 0.6
var _streams := {}
var _players: Array[AudioStreamPlayer] = []
var _last_played := {}        # name -> msec of last playback
var _music_player: AudioStreamPlayer
var _current_music_path := ""

func _ready() -> void:
	for key in SOUNDS.keys():
		_streams[key] = load(SOUNDS[key].path)
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)

	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)
	play_music(MUSIC_MENU)

func play(sound: String) -> void:
	if muted or sfx_volume <= 0.01 or not _streams.has(sound):
		return
	var cfg: Dictionary = SOUNDS[sound]
	var now := Time.get_ticks_msec()
	if cfg.throttle > 0 and _last_played.has(sound):
		if now - _last_played[sound] < cfg.throttle:
			return
	_last_played[sound] = now

	var player := _idle_player()
	if player == null:
		return
	player.stream = _streams[sound]
	player.volume_db = cfg.vol + linear_to_db(sfx_volume)
	player.pitch_scale = 1.0 + randf_range(-cfg.jitter, cfg.jitter)
	player.play()

## ---------- Music ----------
## Switch to a looping track. No-op if already playing the same file.
func play_music(path: String) -> void:
	if path.is_empty() or (path == _current_music_path and _music_player.playing):
		return
	_current_music_path = path
	var raw: AudioStream = load(path)
	if raw == null:
		push_warning("Missing music: %s" % path)
		return
	var stream := raw.duplicate() as AudioStream
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	elif stream is AudioStreamMP3:
		stream.loop = true
	_music_player.stop()
	_music_player.stream = stream
	_music_player.volume_db = _music_db()
	if not muted and music_volume > 0.01:
		_music_player.play()
	_music_player.stream_paused = muted

func play_map_music(map_id: String) -> void:
	var path: String = MUSIC_BY_MAP.get(map_id, "")
	if path.is_empty():
		return
	play_music(path)

func _music_db() -> float:
	if music_volume <= 0.01:
		return -80.0
	return MUSIC_BASE_DB + linear_to_db(music_volume)

func set_sfx_volume(v: float) -> void:
	sfx_volume = clampf(v, 0.0, 1.0)

func set_music_volume(v: float) -> void:
	music_volume = clampf(v, 0.0, 1.0)
	_music_player.volume_db = _music_db()

func _idle_player() -> AudioStreamPlayer:
	for p in _players:
		if not p.playing:
			return p
	# All busy: steal the first one rather than dropping important cues.
	return _players[0]

func set_muted(m: bool) -> void:
	muted = m
	if m:
		for p in _players:
			p.stop()
		_music_player.stream_paused = true
	else:
		_music_player.stream_paused = false
		if not _music_player.playing and _current_music_path != "" and music_volume > 0.01:
			_music_player.play()
