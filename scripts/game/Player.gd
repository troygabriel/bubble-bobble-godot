extends CharacterBody2D

const GameConstants = preload("res://scripts/core/Constants.gd")
const AiAssets = preload("res://scripts/core/AiAssets.gd")

signal bubble_requested(spawn_position: Vector2, direction: int)
signal damaged(lives_left: int)

@export var move_speed := 220.0
@export var jump_velocity := -390.0
@export var gravity_strength := 1100.0
@export var fire_cooldown := 0.28
@export var invulnerability_time := 1.2

var facing := 1
var fire_timer := 0.0
var invulnerability_timer := 0.0
var active_bubbles := 0
var lives := GameConstants.PLAYER_START_LIVES
var spawn_position := GameConstants.PLAYER_SPAWN
var controls_locked := false
var animation_time := 0.0

var visual_root: Node2D
var sprite: Sprite2D


func _ready() -> void:
	add_to_group("player")
	collision_layer = GameConstants.PLAYER_LAYER_MASK
	collision_mask = GameConstants.WORLD_LAYER_MASK
	floor_snap_length = 6.0

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(18, 26)
	collision.shape = shape
	collision.position = Vector2(0, -1)
	add_child(collision)

	visual_root = Node2D.new()
	visual_root.position = Vector2(0, -6)
	add_child(visual_root)

	sprite = Sprite2D.new()
	sprite.texture = AiAssets.player_still()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE * 0.58
	visual_root.add_child(sprite)


func _physics_process(delta: float) -> void:
	animation_time += delta

	if fire_timer > 0.0:
		fire_timer -= delta

	if invulnerability_timer > 0.0:
		invulnerability_timer -= delta
		var blink_frame := int(Time.get_ticks_msec() / 100) % 2
		visual_root.modulate.a = 0.45 if blink_frame == 0 else 1.0
	else:
		visual_root.modulate.a = 1.0

	var axis := 0.0
	if not controls_locked:
		axis = Input.get_axis("move_left", "move_right")
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
			AudioManager.play_sfx(&"jump")
	else:
		axis = 0.0

	if axis != 0.0:
		facing = 1 if axis > 0.0 else -1

	velocity.x = axis * move_speed

	if not is_on_floor():
		velocity.y += gravity_strength * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0

	move_and_slide()
	_update_sprite(axis)

	if not controls_locked and Input.is_action_just_pressed("fire") and fire_timer <= 0.0 and active_bubbles < GameConstants.MAX_ACTIVE_BUBBLES:
		fire_timer = fire_cooldown
		AudioManager.play_sfx(&"fire")
		bubble_requested.emit(global_position + Vector2(24 * facing, -10), facing)


func set_spawn_position(value: Vector2) -> void:
	spawn_position = value


func set_lives(value: int) -> void:
	lives = value


func set_controls_locked(value: bool) -> void:
	controls_locked = value
	if controls_locked:
		velocity.x = 0.0


func register_bubble() -> void:
	active_bubbles += 1


func on_bubble_removed() -> void:
	active_bubbles = max(active_bubbles - 1, 0)


func take_damage() -> void:
	if invulnerability_timer > 0.0 or lives <= 0:
		return

	lives -= 1
	AudioManager.play_sfx(&"hurt")
	velocity = Vector2.ZERO
	if lives > 0:
		global_position = spawn_position
	invulnerability_timer = invulnerability_time
	damaged.emit(lives)


func _update_sprite(axis: float) -> void:
	if invulnerability_timer > invulnerability_time * 0.75:
		sprite.texture = AiAssets.player_recoil(facing)
		return

	if fire_timer > fire_cooldown * 0.45:
		sprite.texture = AiAssets.player_blow(facing)
		return

	if not is_on_floor():
		sprite.texture = AiAssets.player_fall(facing)
		return

	if abs(axis) > 0.1:
		var frames = AiAssets.player_run_frames(facing)
		sprite.texture = frames[int(animation_time * 10.0) % frames.size()]
		return

	sprite.texture = AiAssets.player_still()
