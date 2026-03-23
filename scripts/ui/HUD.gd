extends CanvasLayer

var score_label: Label
var best_label: Label
var round_label: Label
var lives_label: Label
var banner_label: Label


func _ready() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var panel := ColorRect.new()
	panel.position = Vector2(18, 18)
	panel.size = Vector2(410, 84)
	panel.color = Color(0.05, 0.08, 0.13, 0.82)
	root.add_child(panel)

	var accent := ColorRect.new()
	accent.position = panel.position
	accent.size = Vector2(410, 6)
	accent.color = Color(0.95, 0.78, 0.37, 0.95)
	root.add_child(accent)

	score_label = _create_label(root, Vector2(32, 32), Vector2(200, 28), 26, Color(0.98, 0.96, 0.88))
	best_label = _create_label(root, Vector2(32, 62), Vector2(220, 24), 18, Color(0.76, 0.87, 1.0))
	round_label = _create_label(root, Vector2(250, 32), Vector2(160, 28), 24, Color(0.98, 0.84, 0.46))
	round_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lives_label = _create_label(root, Vector2(250, 62), Vector2(160, 24), 18, Color(0.99, 0.62, 0.5))
	lives_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	banner_label = _create_label(root, Vector2(180, 186), Vector2(600, 72), 36, Color(1.0, 0.95, 0.8))
	banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_label.visible = false
	banner_label.add_theme_constant_override("outline_size", 8)
	banner_label.add_theme_color_override("font_outline_color", Color(0.08, 0.12, 0.18, 0.95))


func update_stats(score: int, lives: int, round_number: int, high_score: int) -> void:
	score_label.text = "SCORE %05d" % score
	best_label.text = "BEST %05d" % high_score
	round_label.text = "ROUND %02d" % round_number
	lives_label.text = "LIVES %d" % lives


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
