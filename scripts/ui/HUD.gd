extends CanvasLayer

const AiAssets = preload("res://scripts/core/AiAssets.gd")

var score_label: Label
var best_label: Label
var round_label: Label
var lives_label: Label
var banner_label: Label
var lives_icon_root: Control


func _ready() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var panel := TextureRect.new()
	panel.position = Vector2(12, 12)
	panel.size = Vector2(430, 96)
	panel.texture = AiAssets.hud_panel_texture()
	panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	panel.stretch_mode = TextureRect.STRETCH_SCALE
	root.add_child(panel)

	score_label = _create_label(root, Vector2(32, 28), Vector2(210, 28), 26, Color(0.98, 0.96, 0.88))
	best_label = _create_label(root, Vector2(32, 60), Vector2(220, 24), 18, Color(0.76, 0.87, 1.0))
	round_label = _create_label(root, Vector2(252, 28), Vector2(166, 28), 24, Color(0.98, 0.84, 0.46))
	round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lives_label = _create_label(root, Vector2(254, 60), Vector2(72, 24), 18, Color(0.99, 0.82, 0.6))

	lives_icon_root = Control.new()
	lives_icon_root.position = Vector2(326, 54)
	lives_icon_root.size = Vector2(108, 28)
	root.add_child(lives_icon_root)

	banner_label = _create_label(root, Vector2(180, 186), Vector2(600, 72), 36, Color(1.0, 0.95, 0.8))
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.visible = false
	banner_label.add_theme_constant_override("outline_size", 8)
	banner_label.add_theme_color_override("font_outline_color", Color(0.08, 0.12, 0.18, 0.95))


func update_stats(score: int, lives: int, round_number: int, high_score: int) -> void:
	score_label.text = "SCORE %05d" % score
	best_label.text = "BEST %05d" % high_score
	round_label.text = "ROUND %02d" % round_number
	lives_label.text = "LIVES"
	_update_life_icons(lives)


func show_banner(text: String) -> void:
	banner_label.text = text
	banner_label.visible = true


func hide_banner() -> void:
	banner_label.visible = false


func _create_label(parent: Control, position: Vector2, size: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = position
	label.size = size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label


func _update_life_icons(lives: int) -> void:
	for child in lives_icon_root.get_children():
		child.queue_free()

	for index in range(lives):
		var icon := TextureRect.new()
		icon.position = Vector2(index * 24, 0)
		icon.size = Vector2(20, 20)
		icon.texture = AiAssets.life_icon_texture()
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		lives_icon_root.add_child(icon)
