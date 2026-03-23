extends RefCounted

const SAVE_PATH := "user://bubble_bobble_save.json"


static func load_high_score() -> int:
	if not FileAccess.file_exists(SAVE_PATH):
		return 0

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return 0

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		return int(parsed.get("high_score", 0))

	return 0


static func save_high_score(score: int) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return

	file.store_string(JSON.stringify({"high_score": max(score, 0)}))
