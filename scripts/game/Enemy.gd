extends CharacterBody2D

const GameConstants = preload("res://scripts/core/Constants.gd")
const AiAssets = preload("res://scripts/core/AiAssets.gd")

@export var move_speed := 90.0
@export var gravity_strength := 1100.0

var direction := -1
var state := "active"
var animation_time := 0.0

var visual_root: Node2D
var sprite: Sprite2D
var hurtbox: Area2D


func _ready() -> void:
	add_to_group("enemies")
	collision_layer = GameConstants.ENEMY_LAYER_MASK
	collision_mask = GameConstants.WORLD_LAYER_MASK
	floor_snap_length = 6.0

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(20, 20)
	collision.shape = shape
	collision.position = Vector2(0, -2)
	add_child(collision)

	visual_root = Node2D.new()
	visual_root.position = Vector2(0, -6)
	add_child(visual_root)

	sprite = Sprite2D.new()
	sprite.texture = AiAssets.enemy_walk_frames(-1)[0]
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE * 0.52
	visual_root.add_child(sprite)

	hurtbox = Area2D.new()
	hurtbox.collision_mask = GameConstants.PLAYER_LAYER_MASK
	hurtbox.monitoring = true
	hurtbox.monitorable = false
	var hurt_shape := CollisionShape2D.new()
	hurt_shape.shape = shape.duplicate()
	hurtbox.add_child(hurt_shape)
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	add_child(hurtbox)


func _physics_process(delta: float) -> void:
	animation_time += delta

	if state != "active":
		velocity = Vector2.ZERO
		sprite.visible = false
		return

	sprite.visible = true

	if not is_on_floor():
		velocity.y += gravity_strength * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0

	velocity.x = direction * move_speed
	move_and_slide()

	var should_turn := is_on_wall() or (is_on_floor() and not _has_floor_ahead())
	if should_turn:
		direction *= -1

	var frames = AiAssets.enemy_walk_frames(direction)
	sprite.texture = frames[int(animation_time * 8.0) % frames.size()]


func is_active() -> bool:
	return state == "active"


func capture(_source_bubble: Node) -> void:
	if state != "active":
		return

	state = "trapped"
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	hurtbox.monitoring = false
	sprite.visible = false


func pop_destroy() -> void:
	queue_free()


func _has_floor_ahead() -> bool:
	var ray := PhysicsRayQueryParameters2D.new()
	ray.from = global_position + Vector2(direction * 12.0, 8.0)
	ray.to = global_position + Vector2(direction * 12.0, 30.0)
	ray.exclude = [self]
	ray.collision_mask = GameConstants.WORLD_LAYER_MASK
	var result := get_world_2d().direct_space_state.intersect_ray(ray)
	return not result.is_empty()


func _on_hurtbox_body_entered(body: Node) -> void:
	if state != "active":
		return

	if body.has_method("take_damage"):
		body.take_damage()
