class_name Sfx
extends Node
## Pooled sound playback with per-sound volume, pitch jitter, and throttling.
## Throttle stops rapid-fire sources (six gatlings) from stacking into noise.

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

var muted := false
var _streams := {}
var _players: Array[AudioStreamPlayer] = []
var _last_played := {}        # name -> msec of last playback

func _ready() -> void:
	for key in SOUNDS.keys():
		_streams[key] = load(SOUNDS[key].path)
	for i in range(POOL_SIZE):
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)

func play(sound: String) -> void:
	if muted or not _streams.has(sound):
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
	player.volume_db = cfg.vol
	player.pitch_scale = 1.0 + randf_range(-cfg.jitter, cfg.jitter)
	player.play()

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
