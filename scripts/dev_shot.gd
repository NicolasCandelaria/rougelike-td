extends Node
## Dev-only screenshot hook for menu scenes (game scenes use TD_SHOT in game.gd).
## TD_SHOT_SCENE=/path/out.png godot --path . res://scenes/Upgrades.tscn
## Inert in normal play: does nothing unless the env var is set.

func _ready() -> void:
	var out := OS.get_environment("TD_SHOT_SCENE")
	if out == "":
		return
	await get_tree().create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(out)
	print("[shot] saved ", out)
	get_tree().quit()
