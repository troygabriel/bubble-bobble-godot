extends RefCounted

const PLAYER_SHEET = preload("res://assets_ai/processed/visual/player/player_sheet.png")
const ENEMY_SHEET = preload("res://assets_ai/processed/visual/enemy/enemy_sheet.png")
const ORB_SHEET = preload("res://assets_ai/processed/visual/bubble/orb_sheet.png")
const TRAP_SHEET = preload("res://assets_ai/processed/visual/bubble/trap_sheet.png")
const BACKGROUND_SHEET = preload("res://assets_ai/processed/visual/environment/background_sheet.png")
const BLOCK_SHEET = preload("res://assets_ai/processed/visual/environment/block_tiles.png")
const TITLE_TEXTURE = preload("res://assets_ai/processed/visual/ui/title_screen.png")
const PROMPT_SHEET = preload("res://assets_ai/processed/visual/ui/prompt_sheet.png")
const GAME_OVER_TEXTURE = preload("res://assets_ai/processed/visual/ui/game_over_screen.png")
const HUD_PANEL_TEXTURE = preload("res://assets_ai/processed/visual/ui/hud_panel.png")
const LIFE_ICON_TEXTURE = preload("res://assets_ai/processed/visual/ui/life_icon.png")
const PROJECT_ICON_TEXTURE = preload("res://assets_ai/processed/visual/ui/project_icon.png")

const PLAYER_FRAME_SIZE := Vector2i(64, 64)
const ENEMY_FRAME_SIZE := Vector2i(64, 64)
const ORB_FRAME_SIZE := Vector2i(32, 32)
const TRAP_FRAME_SIZE := Vector2i(64, 64)
const BACKGROUND_FRAME_SIZE := Vector2i(480, 270)
const BLOCK_FRAME_SIZE := Vector2i(32, 32)
const PROMPT_FRAME_SIZE := Vector2i(320, 96)

static var _player_cache: Dictionary = {}
static var _enemy_cache: Dictionary = {}
static var _bubble_cache: Dictionary = {}
static var _background_cache: Array = []
static var _block_cache: Array = []
static var _prompt_cache: Array = []


static func _atlas(texture: Texture2D, column: int, row: int, frame_size: Vector2i) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(column * frame_size.x, row * frame_size.y, frame_size.x, frame_size.y)
	return atlas


static func _ensure_player_cache() -> void:
	if not _player_cache.is_empty():
		return

	_player_cache = {
		"still": _atlas(PLAYER_SHEET, 0, 0, PLAYER_FRAME_SIZE),
		"run_left": [
			_atlas(PLAYER_SHEET, 1, 0, PLAYER_FRAME_SIZE),
			_atlas(PLAYER_SHEET, 2, 0, PLAYER_FRAME_SIZE),
			_atlas(PLAYER_SHEET, 3, 0, PLAYER_FRAME_SIZE),
			_atlas(PLAYER_SHEET, 4, 0, PLAYER_FRAME_SIZE)
		],
		"run_right": [
			_atlas(PLAYER_SHEET, 0, 1, PLAYER_FRAME_SIZE),
			_atlas(PLAYER_SHEET, 1, 1, PLAYER_FRAME_SIZE),
			_atlas(PLAYER_SHEET, 2, 1, PLAYER_FRAME_SIZE),
			_atlas(PLAYER_SHEET, 3, 1, PLAYER_FRAME_SIZE)
		],
		"blow_left": _atlas(PLAYER_SHEET, 4, 1, PLAYER_FRAME_SIZE),
		"blow_right": _atlas(PLAYER_SHEET, 0, 2, PLAYER_FRAME_SIZE),
		"recoil_left": _atlas(PLAYER_SHEET, 1, 2, PLAYER_FRAME_SIZE),
		"recoil_right": _atlas(PLAYER_SHEET, 2, 2, PLAYER_FRAME_SIZE),
		"fall_left": _atlas(PLAYER_SHEET, 3, 2, PLAYER_FRAME_SIZE),
		"fall_right": _atlas(PLAYER_SHEET, 4, 2, PLAYER_FRAME_SIZE)
	}


static func player_still() -> Texture2D:
	_ensure_player_cache()
	return _player_cache["still"]


static func player_run_frames(direction: int) -> Array:
	_ensure_player_cache()
	return _player_cache["run_right"] if direction > 0 else _player_cache["run_left"]


static func player_blow(direction: int) -> Texture2D:
	_ensure_player_cache()
	return _player_cache["blow_right"] if direction > 0 else _player_cache["blow_left"]


static func player_recoil(direction: int) -> Texture2D:
	_ensure_player_cache()
	return _player_cache["recoil_right"] if direction > 0 else _player_cache["recoil_left"]


static func player_fall(direction: int) -> Texture2D:
	_ensure_player_cache()
	return _player_cache["fall_right"] if direction > 0 else _player_cache["fall_left"]


static func _ensure_enemy_cache() -> void:
	if not _enemy_cache.is_empty():
		return

	_enemy_cache = {
		"left": [
			_atlas(ENEMY_SHEET, 0, 0, ENEMY_FRAME_SIZE),
			_atlas(ENEMY_SHEET, 1, 0, ENEMY_FRAME_SIZE),
			_atlas(ENEMY_SHEET, 2, 0, ENEMY_FRAME_SIZE),
			_atlas(ENEMY_SHEET, 3, 0, ENEMY_FRAME_SIZE)
		],
		"right": [
			_atlas(ENEMY_SHEET, 0, 1, ENEMY_FRAME_SIZE),
			_atlas(ENEMY_SHEET, 1, 1, ENEMY_FRAME_SIZE),
			_atlas(ENEMY_SHEET, 2, 1, ENEMY_FRAME_SIZE),
			_atlas(ENEMY_SHEET, 3, 1, ENEMY_FRAME_SIZE)
		]
	}


static func enemy_walk_frames(direction: int) -> Array:
	_ensure_enemy_cache()
	return _enemy_cache["right"] if direction > 0 else _enemy_cache["left"]


static func _ensure_bubble_cache() -> void:
	if not _bubble_cache.is_empty():
		return

	var orb_frames: Array = []
	for index in range(7):
		orb_frames.append(_atlas(ORB_SHEET, index, 0, ORB_FRAME_SIZE))

	var trap_frames: Array = []
	for index in range(8):
		trap_frames.append(_atlas(TRAP_SHEET, index, 0, TRAP_FRAME_SIZE))

	_bubble_cache = {
		"orb": orb_frames,
		"trap": trap_frames
	}


static func bubble_orb_frames() -> Array:
	_ensure_bubble_cache()
	return _bubble_cache["orb"]


static func bubble_trap_frames() -> Array:
	_ensure_bubble_cache()
	return _bubble_cache["trap"]


static func _ensure_background_cache() -> void:
	if not _background_cache.is_empty():
		return

	_background_cache = [
		_atlas(BACKGROUND_SHEET, 0, 0, BACKGROUND_FRAME_SIZE),
		_atlas(BACKGROUND_SHEET, 1, 0, BACKGROUND_FRAME_SIZE),
		_atlas(BACKGROUND_SHEET, 0, 1, BACKGROUND_FRAME_SIZE),
		_atlas(BACKGROUND_SHEET, 1, 1, BACKGROUND_FRAME_SIZE)
	]


static func background_texture(index: int) -> Texture2D:
	_ensure_background_cache()
	return _background_cache[clampi(index, 0, _background_cache.size() - 1)]


static func _ensure_block_cache() -> void:
	if not _block_cache.is_empty():
		return

	for index in range(4):
		_block_cache.append(_atlas(BLOCK_SHEET, index, 0, BLOCK_FRAME_SIZE))


static func block_texture(index: int) -> Texture2D:
	_ensure_block_cache()
	return _block_cache[clampi(index, 0, _block_cache.size() - 1)]


static func block_atlas_coords(index: int) -> Vector2i:
	return Vector2i(clampi(index, 0, 3), 0)


static func _ensure_prompt_cache() -> void:
	if not _prompt_cache.is_empty():
		return

	for row in range(2):
		for column in range(5):
			_prompt_cache.append(_atlas(PROMPT_SHEET, column, row, PROMPT_FRAME_SIZE))


static func prompt_frames() -> Array:
	_ensure_prompt_cache()
	return _prompt_cache


static func title_texture() -> Texture2D:
	return TITLE_TEXTURE


static func game_over_texture() -> Texture2D:
	return GAME_OVER_TEXTURE


static func hud_panel_texture() -> Texture2D:
	return HUD_PANEL_TEXTURE


static func life_icon_texture() -> Texture2D:
	return LIFE_ICON_TEXTURE


static func project_icon_texture() -> Texture2D:
	return PROJECT_ICON_TEXTURE
