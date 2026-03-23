extends Control

const AiAssets = preload("res://scripts/core/AiAssets.gd")

signal start_requested

var high_score := 0
var prompt_rect: TextureRect
var pulse_time := 0.0


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var background := TextureRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.texture = AiAssets.title_texture()
	background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(background)

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.02, 0.04, 0.08, 0.2)
	add_child(overlay)

	var panel := ColorRect.new()
	panel.position = Vector2(560, 72)
	panel.size = Vector2(338, 356)
	panel.color = Color(0.03, 0.06, 0.1, 0.82)
	add_child(panel)

	var accent := ColorRect.new()
	accent.position = panel.position
	accent.size = Vector2(panel.size.x, 8)
	accent.color = Color(0.95, 0.78, 0.33, 0.95)
	add_child(accent)

	var subtitle := _create_label("Bubble Bobble-style single-screen platformer", Vector2(582, 96), Vector2(292, 44), 24, Color(0.98, 0.95, 0.83))
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(subtitle)

	var controls := _create_label("Controls\nA / Left  Move\nD / Right Move\nW / Up    Jump\nSpace     Fire bubble\nEnter     Start", Vector2(584, 166), Vector2(270, 150), 22, Color(0.86, 0.95, 1.0))
	controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(controls)

	var features := _create_label("Features\nBubble trapping\nEnemy patrols\nRound loop\nSaved best score", Vector2(584, 292), Vector2(250, 108), 22, Color(0.95, 0.83, 0.63))
	features.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(features)

	var best := _create_label("BEST SCORE %05d" % high_score, Vector2(584, 394), Vector2(260, 30), 24, Color(0.72, 0.94, 0.84))
	add_child(best)

	prompt_rect = TextureRect.new()
	prompt_rect.position = Vector2(118, 292)
	prompt_rect.size = Vector2(344, 88)
	prompt_rect.texture = AiAssets.prompt_frames()[0]
	prompt_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	prompt_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	add_child(prompt_rect)

	var enter_note := _create_label("Press Space or Enter", Vector2(140, 382), Vector2(300, 28), 24, Color(1.0, 0.96, 0.88))
	enter_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(enter_note)


func _process(delta: float) -> void:
	pulse_time += delta
	var frames = AiAssets.prompt_frames()
	prompt_rect.texture = frames[int(pulse_time * 10.0) % frames.size()]
	prompt_rect.modulate.a = 0.72 + 0.28 * abs(sin(pulse_time * 2.4))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_echo():
		return

	if event.is_action_pressed("start") or event.is_action_pressed("fire"):
		AudioManager.play_sfx(&"start")
		start_requested.emit()


func _create_label(text: String, position: Vector2, size: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = position
	label.size = size
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("line_spacing", 6)
	return label
