extends Area2D

const GameConstants = preload("res://scripts/core/Constants.gd")

const ORB_FRAMES := [
	preload("res://assets/sprites/cavern/orb0.png"),
	preload("res://assets/sprites/cavern/orb1.png"),
	preload("res://assets/sprites/cavern/orb2.png"),
	preload("res://assets/sprites/cavern/orb3.png"),
	preload("res://assets/sprites/cavern/orb4.png"),
	preload("res://assets/sprites/cavern/orb5.png"),
	preload("res://assets/sprites/cavern/orb6.png")
]
const TRAP_FRAMES := [
	preload("res://assets/sprites/cavern/trap00.png"),
	preload("res://assets/sprites/cavern/trap01.png"),
	preload("res://assets/sprites/cavern/trap02.png"),
	preload("res://assets/sprites/cavern/trap03.png"),
	preload("res://assets/sprites/cavern/trap04.png"),
	preload("res://assets/sprites/cavern/trap05.png"),
	preload("res://assets/sprites/cavern/trap06.png"),
	preload("res://assets/sprites/cavern/trap07.png")
]

signal trapped(enemy: Node)
signal popped(points_awarded: int)

@export var horizontal_speed := 250.0
@export var upward_speed := 86.0
@export var horizontal_duration := 0.55
@export var free_lifetime := 3.5

var direction := 1
var age := 0.0
var hover_time := 0.0
var trapped_enemy: Node

var sprite: Sprite2D


func _ready() -> void:
	add_to_group("bubbles")
	collision_layer = GameConstants.BUBBLE_LAYER_MASK
	collision_mask = GameConstants.PLAYER_LAYER_MASK | GameConstants.ENEMY_LAYER_MASK
	monitoring = true
	monitorable = true
	body_entered.connect(_on_body_entered)

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 12.0
	collision.shape = shape
	add_child(collision)

	sprite = Sprite2D.new()
	sprite.texture = ORB_FRAMES[0]
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE * 2.0
	add_child(sprite)


func _physics_process(delta: float) -> void:
	age += delta

	if trapped_enemy == null:
		if age <= horizontal_duration:
			global_position.x += direction * horizontal_speed * delta
		else:
			global_position.x += direction * horizontal_speed * 0.14 * delta
			global_position.y -= upward_speed * delta

		if age >= free_lifetime or global_position.y < 18.0:
			queue_free()
	else:
		hover_time += delta
		global_position.y = max(global_position.y - upward_speed * 0.45 * delta, GameConstants.TRAPPED_BUBBLE_CEILING_Y)
		global_position.x += sin(hover_time * 3.5) * 18.0 * delta
		if is_instance_valid(trapped_enemy):
			trapped_enemy.global_position = global_position

	global_position.x = clamp(global_position.x, 18.0, GameConstants.VIEW_SIZE.x - 18.0)
	_update_sprite()


func _on_body_entered(body: Node) -> void:
	if trapped_enemy == null and body.is_in_group("enemies") and body.has_method("is_active") and body.is_active():
		trap_enemy(body)
	elif trapped_enemy != null and body.is_in_group("player"):
		pop()


func trap_enemy(enemy: Node) -> void:
	if trapped_enemy != null:
		return

	trapped_enemy = enemy
	trapped_enemy.capture(self)
	trapped.emit(enemy)
	_update_sprite()


func pop() -> void:
	if trapped_enemy != null and is_instance_valid(trapped_enemy):
		trapped_enemy.pop_destroy()
		trapped_enemy = null
		popped.emit(GameConstants.POINTS_PER_POP)
	queue_free()


func _update_sprite() -> void:
	var pulse := 1.0 + 0.05 * sin(age * 8.0)
	if trapped_enemy == null:
		var frame: int = clampi(int(age * 12.0), 0, ORB_FRAMES.size() - 1)
		if age > horizontal_duration:
			frame = 3 + int(age * 6.0) % 4
		sprite.texture = ORB_FRAMES[frame]
		sprite.scale = Vector2.ONE * (2.0 * pulse)
	else:
		sprite.texture = TRAP_FRAMES[int(hover_time * 6.0) % TRAP_FRAMES.size()]
		sprite.scale = Vector2.ONE * (0.36 * pulse)
