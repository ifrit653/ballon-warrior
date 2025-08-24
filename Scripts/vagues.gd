extends Node2D

# Movement parameters
@export var initial_speed: float = 25.0  # Starting speed (pixels per second)
@export var acceleration: float = 10.0   # How fast the speed increases
@export var max_speed: float = 3000000    # Maximum speed limit (optional)

@onready var game_manager := %GameManager

# Internal variables
var current_speed: float
var is_moving: bool = false

func _ready():
	current_speed = initial_speed
	start_movement()

func start_movement():
	is_moving = true

func stop_movement():
	is_moving = false

func reset_movement():
	current_speed = initial_speed
	elapsed_time = 0.0
	is_moving = false

func _process(delta):
	if is_moving:
		# Increase speed over time
		current_speed += acceleration * delta
		
		# Optional: Cap the maximum speed
		if max_speed > 0:
			current_speed = min(current_speed, max_speed)
		
		# Move the block upward (negative Y direction)
		position.y -= current_speed * delta
	if game_manager.game_state == "over":
		current_speed = 1000.0
		 

# Optional: Stop when reaching a certain height
func _check_bounds():
	# Example: Stop when block reaches Y position -1000
	if position.y <= -1000:
		stop_movement()

# Track elapsed time for curve-based acceleration
var elapsed_time: float = 0.0

# Alternative version with easing curve for smoother acceleration
func _process_with_curve(delta):
	if is_moving:
		elapsed_time += delta
		
		# Use a quadratic curve for smooth acceleration
		var speed_multiplier = pow(elapsed_time * 0.1, 2)
		current_speed = initial_speed + (speed_multiplier * acceleration)
		
		if max_speed > 0:
			current_speed = min(current_speed, max_speed)
		
		position.y -= current_speed * delta
