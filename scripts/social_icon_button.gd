class_name SocialIconButton
extends Control
## Clickable social link button with a drawn brand icon.

enum Kind { LINKEDIN, GITHUB }

var kind: Kind = Kind.LINKEDIN
var _callback: Callable

func _init() -> void:
	custom_minimum_size = Vector2(52, 52)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func setup(link_kind: Kind, tooltip: String, callback: Callable) -> void:
	kind = link_kind
	tooltip_text = tooltip
	_callback = callback
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_callback.call()

func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	draw_rect(r, Color(1, 1, 1, 0.06), false, 1.5)
	draw_rect(r.grow(-1), Color(0.12, 0.16, 0.22), true)
	match kind:
		Kind.LINKEDIN:
			_draw_linkedin()
		Kind.GITHUB:
			_draw_github()

func _draw_linkedin() -> void:
	var c := size * 0.5
	draw_rect(Rect2(c.x - 14, c.y - 10, 28, 20), Color(0.0, 0.47, 0.71, 0.25), true)
	draw_string(ThemeDB.fallback_font, Vector2(c.x - 9, c.y + 6), "in",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.0, 0.65, 0.95))

func _draw_github() -> void:
	var c := size * 0.5
	draw_circle(c, 13.0, Color(1, 1, 1, 0.88))
	draw_circle(c, 11.0, Color(0.12, 0.16, 0.22))
	draw_arc(c + Vector2(0, 2), 7.0, 0.0, TAU, 20, Color(1, 1, 1, 0.9), 2.0)
	draw_rect(Rect2(c.x - 5, c.y - 7, 3, 5), Color(1, 1, 1, 0.9))
	draw_rect(Rect2(c.x + 2, c.y - 7, 3, 5), Color(1, 1, 1, 0.9))
