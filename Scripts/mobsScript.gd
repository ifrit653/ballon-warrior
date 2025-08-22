extends RigidBody2D

const SPEED := 150.0
const FLIGHT_FORCE := 400.0

@onready var sprite: Sprite2D = $Sprite2D

# --- Flight constraints (relative to spawn) ---
var spawn_position: Vector2
@export var max_height: float = 200.0   # max distance above spawn
@export var max_left: float = 200.0     # max distance left of spawn
@export var max_right: float = 200.0    # max distance right of spawn

# Timer for random direction shifts
var movement_timer: Timer
var current_direction: Vector2 = Vector2.ZERO

# Random change intervals (seconds)
@export var min_dir_change_time: float = 2.0
@export var max_dir_change_time: float = 5.0

# Smoothness factor for bouncing/steering
@export var steer_strength: float = 0.1

func _ready() -> void:
	spawn_position = global_position
	
	# Configure RigidBody2D for flight
	gravity_scale = 0.0
	linear_damp = 0.5
	
	setup_timer()
	choose_random_direction()

func setup_timer() -> void:
	movement_timer = Timer.new()
	movement_timer.one_shot = true
	add_child(movement_timer)
	movement_timer.timeout.connect(_on_movement_timer_timeout)

func _physics_process(delta: float) -> void:
	# Flip sprite depending on movement
	if current_direction.x > 0:
		sprite.flip_h = true
	elif current_direction.x < 0:
		sprite.flip_h = false
	
	var future_position = global_position + current_direction * SPEED * delta
	var desired_direction = current_direction
	
	# --- SOFT BOUNCE CONSTRAINTS ---
	if future_position.y > spawn_position.y:
		# Below spawn → steer upward
		desired_direction = Vector2(current_direction.x, -1).normalized()
	elif future_position.y < spawn_position.y - max_height:
		# Too high → steer downward
		desired_direction = Vector2(current_direction.x, 1).normalized()
	
	if future_position.x < spawn_position.x - max_left:
		# Too far left → steer right
		desired_direction = Vector2(1, current_direction.y).normalized()
	elif future_position.x > spawn_position.x + max_right:
		# Too far right → steer left
		desired_direction = Vector2(-1, current_direction.y).normalized()
	
	# Smoothly adjust direction toward the desired one
	current_direction = current_direction.lerp(desired_direction, steer_strength).normalized()
	
	# Always keep flying
	linear_velocity = current_direction * SPEED

# --- Random direction selection ---
func choose_random_direction() -> void:
	var angle = randf() * TAU
	var dir = Vector2(cos(angle), sin(angle)).normalized()
	
	# Don’t allow downward start if already at spawn height
	if global_position.y >= spawn_position.y and dir.y > 0:
		dir.y = -abs(dir.y)
	
	current_direction = dir
	restart_movement_timer()

func restart_movement_timer() -> void:
	var wait_time = randf_range(min_dir_change_time, max_dir_change_time)
	movement_timer.start(wait_time)

func _on_movement_timer_timeout() -> void:
	choose_random_direction()
