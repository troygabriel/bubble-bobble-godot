extends Control

const AiAssets = preload("res://scripts/core/AiAssets.gd")

signal restart_requested

var score := 0
var high_score := 0
var prompt_label: Label
var pulse_time := 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var background := TextureRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.texture = AiAssets.game_over_texture()
	background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(background)

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.08, 0.03, 0.05, 0.28)
	add_child(overlay)

	var panel := ColorRect.new()
	panel.position = Vector2(474, 112)
	panel.size = Vector2(330, 230)
	panel.color = Color(0.08, 0.03, 0.05, 0.86)
	add_child(panel)

	var accent := ColorRect.new()
	accent.position = panel.position
	accent.size = Vector2(panel.size.x, 8)
	accent.color = Color(0.95, 0.41, 0.35, 0.95)
	add_child(accent)

	var score_label := _create_label("FINAL SCORE %05d" % score, Vector2(496, 156), Vector2(286, 34), 26, Color(1.0, 0.85, 0.58))
	add_child(score_label)

	var best_label := _create_label("BEST SCORE %05d" % high_score, Vector2(496, 202), Vector2(286, 30), 22, Color(0.74, 0.94, 0.84))
	add_child(best_label)

	var note := _create_label("Touch trapped bubbles to pop them and clear the room. Press fire or restart to go again.", Vector2(496, 246), Vector2(270, 68), 18, Color(0.95, 0.91, 0.96))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(note)

	prompt_label = _create_label("PRESS SPACE, ENTER, OR R", Vector2(490, 314), Vector2(292, 28), 20, Color(1.0, 0.95, 0.88))
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(prompt_label)


func _process(delta: float) -> void:
	pulse_time += delta
	prompt_label.modulate.a = 0.5 + 0.5 * abs(sin(pulse_time * 2.8))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_echo():
		return

	if event.is_action_pressed("restart") or event.is_action_pressed("start") or event.is_action_pressed("fire"):
		AudioManager.play_sfx(&"start")
		restart_requested.emit()


func _create_label(text: String, position: Vector2, size: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = position
	label.size = size
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("line_spacing", 6)
	return label
