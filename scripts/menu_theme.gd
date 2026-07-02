class_name MenuTheme
extends RefCounted
## Shared styling for menu screens.

const BG := Color(0.06, 0.09, 0.14)
const PANEL := Color(0.10, 0.14, 0.20, 0.92)
const ACCENT := Color(0.35, 0.75, 1.0)
const TEXT_DIM := Color(1, 1, 1, 0.62)
const BTN_MIN := Vector2(280, 52)

static func apply_bg(node: Control) -> ColorRect:
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	node.add_child(bg)
	return bg

static func style_title(label: Label, size := 48) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

static func style_button(btn: Button, large := true) -> void:
	if large:
		btn.custom_minimum_size = BTN_MIN
		btn.add_theme_font_size_override("font_size", 20)

static func make_panel() -> PanelContainer:
	var p := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = PANEL
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	p.add_theme_stylebox_override("panel", sb)
	return p
