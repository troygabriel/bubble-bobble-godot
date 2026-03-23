extends Node2D

const GameConstants = preload("res://scripts/core/Constants.gd")
const PlayerScript = preload("res://scripts/game/Player.gd")
const EnemyScript = preload("res://scripts/game/Enemy.gd")
const BubbleScript = preload("res://scripts/game/Bubble.gd")
const HUDScript = preload("res://scripts/ui/HUD.gd")
const AiAssets = preload("res://scripts/core/AiAssets.gd")

signal round_cleared(score: int, lives: int, next_round: int)
signal game_over(final_score: int)

var round_number := 1
var starting_score := 0
var starting_lives := GameConstants.PLAYER_START_LIVES
var high_score := 0

var score := 0
var lives := 0
var tile_source_id := 0
var remaining_enemies := 0
var state_locked := false

var tile_map: TileMap
var player: CharacterBody2D
var hud: CanvasLayer
var bubble_container: Node2D
var enemy_container: Node2D


func _ready() -> void:
	score = starting_score
	lives = starting_lives

	_create_background()
	_build_tile_map()

	enemy_container = Node2D.new()
	enemy_container.name = "Enemies"
	enemy_container.z_index = 4
	add_child(enemy_container)

	bubble_container = Node2D.new()
	bubble_container.name = "Bubbles"
	bubble_container.z_index = 5
	add_child(bubble_container)

	_spawn_player()
	_spawn_enemies()
	_create_hud()
	_refresh_hud()

	hud.show_banner("ROUND %02d" % round_number)
	_hide_banner_after_delay(1.0)


func _create_background() -> void:
	var background := Sprite2D.new()
	background.texture = AiAssets.background_texture((round_number - 1) % 4)
	background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	background.centered = false
	background.position = Vector2.ZERO
	background.scale = Vector2(
		GameConstants.VIEW_SIZE.x / float(background.texture.get_width()),
		GameConstants.VIEW_SIZE.y / float(background.texture.get_height())
	)
	background.z_index = 0
	add_child(background)


func _build_tile_map() -> void:
	tile_map = TileMap.new()
	tile_map.name = "TileMap"
	tile_map.z_index = 2
	if tile_map.get_layers_count() == 0:
		tile_map.add_layer(0)
	tile_map.tile_set = _create_tile_set()
	add_child(tile_map)

	_fill_column(0, 0, 16)
	_fill_column(29, 0, 16)
	_fill_row(16, 0, 29)
	_fill_row(12, 3, 10)
	_fill_row(12, 19, 26)
	_fill_row(9, 7, 22)
	_fill_row(6, 4, 11)
	_fill_row(6, 18, 25)
	_fill_row(3, 10, 19)


func _create_tile_set() -> TileSet:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(GameConstants.TILE_SIZE, GameConstants.TILE_SIZE)
	tileset.add_physics_layer()
	tileset.set_physics_layer_collision_layer(0, GameConstants.WORLD_LAYER_MASK)
	tileset.set_physics_layer_collision_mask(0, GameConstants.PLAYER_LAYER_MASK | GameConstants.ENEMY_LAYER_MASK)

	var source := TileSetAtlasSource.new()
	source.texture = AiAssets.BLOCK_SHEET
	source.texture_region_size = AiAssets.BLOCK_FRAME_SIZE
	tile_source_id = tileset.add_source(source, 0)
	var atlas_source: TileSetAtlasSource = tileset.get_source(tile_source_id)
	for index in range(4):
		var atlas_coords := Vector2i(index, 0)
		atlas_source.create_tile(atlas_coords)
		var tile_data := atlas_source.get_tile_data(atlas_coords, 0)
		tile_data.add_collision_polygon(0)
		tile_data.set_collision_polygon_points(0, 0, PackedVector2Array([
			Vector2.ZERO,
			Vector2(GameConstants.TILE_SIZE, 0),
			Vector2(GameConstants.TILE_SIZE, GameConstants.TILE_SIZE),
			Vector2(0, GameConstants.TILE_SIZE)
		]))

	return tileset


func _fill_row(y: int, start_x: int, end_x: int) -> void:
	var atlas_coords := AiAssets.block_atlas_coords((round_number - 1) % 4)
	for x in range(start_x, end_x + 1):
		tile_map.set_cell(0, Vector2i(x, y), tile_source_id, atlas_coords, 0)


func _fill_column(x: int, start_y: int, end_y: int) -> void:
	var atlas_coords := AiAssets.block_atlas_coords((round_number - 1) % 4)
	for y in range(start_y, end_y + 1):
		tile_map.set_cell(0, Vector2i(x, y), tile_source_id, atlas_coords, 0)


func _spawn_player() -> void:
	player = PlayerScript.new()
	player.global_position = GameConstants.PLAYER_SPAWN
	player.set_spawn_position(GameConstants.PLAYER_SPAWN)
	player.set_lives(lives)
	player.z_index = 6
	player.bubble_requested.connect(_on_player_bubble_requested)
	player.damaged.connect(_on_player_damaged)
	add_child(player)


func _spawn_enemies() -> void:
	var spawn_points := [
		Vector2(208, 500),
		Vector2(752, 500),
		Vector2(288, 372),
		Vector2(672, 372),
		Vector2(480, 276),
		Vector2(480, 84)
	]

	remaining_enemies = min(GameConstants.BASE_ENEMY_COUNT + round_number - 1, GameConstants.MAX_ENEMY_COUNT)

	for index in range(remaining_enemies):
		var enemy := EnemyScript.new()
		enemy.global_position = spawn_points[index]
		enemy.direction = -1 if index % 2 == 0 else 1
		enemy.move_speed = 86.0 + float(round_number - 1) * 10.0
		enemy_container.add_child(enemy)


func _create_hud() -> void:
	hud = HUDScript.new()
	add_child(hud)


func _refresh_hud() -> void:
	hud.update_stats(score, lives, round_number, max(score, high_score))


func _on_player_bubble_requested(spawn_position: Vector2, direction: int) -> void:
	if state_locked:
		return

	var bubble := BubbleScript.new()
	bubble.global_position = spawn_position
	bubble.direction = direction
	bubble.popped.connect(_on_bubble_popped)
	bubble.tree_exiting.connect(_on_bubble_removed)
	bubble_container.add_child(bubble)
	player.register_bubble()


func _on_bubble_removed() -> void:
	if is_instance_valid(player):
		player.on_bubble_removed()


func _on_bubble_popped(points_awarded: int) -> void:
	if state_locked:
		return

	score += points_awarded
	remaining_enemies -= 1
	_refresh_hud()

	if remaining_enemies <= 0:
		_handle_round_clear()


func _on_player_damaged(lives_left: int) -> void:
	lives = lives_left
	_refresh_hud()

	if lives <= 0 and not state_locked:
		_handle_game_over()


func _handle_round_clear() -> void:
	state_locked = true
	player.set_controls_locked(true)
	AudioManager.play_sfx(&"clear")
	hud.show_banner("ROUND %02d CLEAR" % round_number)
	await get_tree().create_timer(GameConstants.ROUND_TRANSITION_TIME).timeout
	round_cleared.emit(score, lives, round_number + 1)


func _handle_game_over() -> void:
	state_locked = true
	player.set_controls_locked(true)
	AudioManager.play_sfx(&"game_over")
	hud.show_banner("GAME OVER")
	await get_tree().create_timer(GameConstants.ROUND_TRANSITION_TIME).timeout
	game_over.emit(score)


func _hide_banner_after_delay(delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	if is_instance_valid(hud) and not state_locked:
		hud.hide_banner()
