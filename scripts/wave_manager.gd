class_name WaveManager
extends Node

signal spawn_enemy(type_id: String, wave: int, spawn_idx: int)
signal all_spawned

var _queue: Array = []        # [{time, type, spawn}] sorted by time
var _clock := 0.0
var _wave := 0
var active := false

func start_wave(wave: int, map_index := 0) -> void:
	_wave = wave
	_clock = 0.0
	_queue.clear()
	for group in GameData.wave_groups(wave, map_index):
		var spawn_idx: int = group.get("spawn", 0)
		for i in range(group.n):
			_queue.append({time = group.delay + i * group.gap, type = group.t, spawn = spawn_idx})
	_queue.sort_custom(func(a, b): return a.time < b.time)
	active = true

func pending_count() -> int:
	return _queue.size()

func _physics_process(delta: float) -> void:
	if not active:
		return
	_clock += delta
	while _queue.size() > 0 and _queue[0].time <= _clock:
		var item: Dictionary = _queue.pop_front()
		spawn_enemy.emit(item.type, _wave, item.spawn)
	if _queue.is_empty():
		active = false
		all_spawned.emit()
