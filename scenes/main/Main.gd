extends Node

const GameConstants = preload("res://scripts/core/Constants.gd")
const SaveSystem = preload("res://scripts/core/Save.gd")
const Level01 = preload("res://scripts/game/Level01.gd")
const MenuScreen = preload("res://scripts/ui/MenuScreen.gd")
const GameOverScreen = preload("res://scripts/ui/GameOverScreen.gd")

var current_screen: Control
var current_level: Node
var current_round := 1
var current_score := 0
var current_lives := GameConstants.PLAYER_START_LIVES
var high_score := 0


func _ready() -> void:
	_ensure_input_map()
	high_score = SaveSystem.load_high_score()
	_show_menu()


func _show_menu() -> void:
	_clear_current_nodes()
	current_round = 1
	current_score = 0
	current_lives = GameConstants.PLAYER_START_LIVES

	var menu := MenuScreen.new()
	menu.high_score = high_score
	menu.start_requested.connect(_start_new_game)
	add_child(menu)
	current_screen = menu


func _start_new_game() -> void:
	current_round = 1
	current_score = 0
	current_lives = GameConstants.PLAYER_START_LIVES
	_start_round()


func _start_round() -> void:
	_clear_current_nodes()

	var level := Level01.new()
	level.round_number = current_round
	level.starting_score = current_score
	level.starting_lives = current_lives
	level.high_score = high_score
	level.round_cleared.connect(_on_round_cleared)
	level.game_over.connect(_on_game_over)
	add_child(level)
	current_level = level


func _on_round_cleared(score: int, lives: int, next_round: int) -> void:
	current_score = score
	current_lives = lives
	current_round = next_round
	high_score = max(high_score, current_score)
	SaveSystem.save_high_score(high_score)
	_start_round()


func _on_game_over(final_score: int) -> void:
	current_score = final_score
	high_score = max(high_score, final_score)
	SaveSystem.save_high_score(high_score)
	_clear_current_nodes()

	var game_over := GameOverScreen.new()
	game_over.score = final_score
	game_over.high_score = high_score
	game_over.restart_requested.connect(_start_new_game)
	add_child(game_over)
	current_screen = game_over


func _clear_current_nodes() -> void:
	if is_instance_valid(current_level):
		current_level.queue_free()
		current_level = null

	if is_instance_valid(current_screen):
		current_screen.queue_free()
		current_screen = null


func _ensure_input_map() -> void:
	_register_action("move_left", [KEY_A, KEY_LEFT])
	_register_action("move_right", [KEY_D, KEY_RIGHT])
	_register_action("jump", [KEY_W, KEY_UP])
	_register_action("fire", [KEY_SPACE])
	_register_action("start", [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE])
	_register_action("restart", [KEY_R])


func _register_action(action_name: StringName, keys: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	if not InputMap.action_get_events(action_name).is_empty():
		return

	for key in keys:
		var event := InputEventKey.new()
		event.keycode = key
		event.physical_keycode = key
		InputMap.action_add_event(action_name, event)
