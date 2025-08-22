extends RigidBody2D

const SPEED := 150.0
@onready var player: CharacterBody2D = $"../Node2D"

@onready var sprite: Sprite2D = $Sprite2D
@onready var ray_right: RayCast2D = $RayCast2Dhighreight
@onready var ray_left: RayCast2D = $RayCast2Dhighleft
@onready var ray_low_left: RayCast2D = $RayCast2Dlowleft2
@onready var ray_low_right: RayCast2D = $RayCast2Dlowright

var spawn_position: Vector2
var direction: Vector2 = Vector2.RIGHT
var timer: Timer

# Wing flapping variables
var flap_time: float = 0.0
var base_y: float = 0.0

# --- Patrol ranges ---
@export var patrol_range_x: float = 250.0   # Horizontal range
@export var patrol_range_y: float = 30.0   # Vertical range
@export var direction_change_time: float = 3.0
@export var flap_speed: float = 3.0  # How fast the wings flap
@export var flap_height: float = 10.0  # How much up/down movement

func _ready() -> void:
	spawn_position = global_position
	base_y = global_position.y  # Store the base flying height
	
	# Prevent physics rotation glitches
	freeze = false
	lock_rotation = true
	gravity_scale = 0.0
	
	# Timer for random direction changes
	timer = Timer.new()
	timer.wait_time = direction_change_time
	timer.timeout.connect(choose_direction)
	add_child(timer)
	timer.start()

func _physics_process(delta: float) -> void:
	# Update flapping animation
	flap_time += delta
	var flap_offset = sin(flap_time * flap_speed) * flap_height
	
	# Create movement with flapping motion
	var movement = direction * SPEED
	movement.y += flap_offset * 20  # Add flapping to velocity
	
	linear_velocity = movement
	
	# Check patrol bounds
	if global_position.x < spawn_position.x - patrol_range_x:
		direction.x = 1
	elif global_position.x > spawn_position.x + patrol_range_x:
		direction.x = -1

	if global_position.y < spawn_position.y - patrol_range_y:
		direction.y = 1
	elif global_position.y > spawn_position.y + patrol_range_y:
		direction.y = -1

	
	# Raycast collision reactions
	if ray_right.is_colliding():
		direction.x = -1  # Go left when hitting right
	elif ray_left.is_colliding():
		direction.x = 1   # Go right when hitting left
	
	if ray_low_right.is_colliding():
		direction.x = -1  # Go left when hitting right
	elif ray_low_left.is_colliding():
		direction.x = 1   # Go right when hitting left
	
	# Always update sprite facing based on current direction
	if direction.x > 0:
		sprite.flip_h = true   # Face right
	elif direction.x < 0:
		sprite.flip_h = false  # Face left

func choose_direction() -> void:
	# Pick a new random direction
	direction = Vector2(
		randf_range(-1, 1),
		randf_range(-0.5, 0.5)
	).normalized()
	
	timer.start()


var y_delta
var health_decrease_count = 0  # Track how many times health decreased

func _on_area_2d_body_entered(body):
	if (body == player):
		var y_delta = position.y - body.position.y
		if (y_delta > 50.0):
			print("Destroy enemy") 
			queue_free()
		else:
			print("Decrease player health")
			health_decrease_count += 1
			
			# Check if health decreased twice
			if health_decrease_count >= 2:
				get_tree().reload_current_scene()
