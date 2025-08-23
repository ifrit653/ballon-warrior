extends RigidBody2D

@onready var player = get_node("%Player")

const SPEED := 150.0
const CHASE_SPEED := 200.0  # Faster when chasing

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_right: RayCast2D = $RayCast2Dhighreight
@onready var ray_left: RayCast2D = $RayCast2Dhighleft
@onready var ray_low_left: RayCast2D = $RayCast2Dlowleft2
@onready var ray_low_right: RayCast2D = $RayCast2Dlowright
@onready var player_death: AudioStreamPlayer = $"player death"
@onready var mob_sfx: AudioStreamPlayer2D = $mob_sfx
@onready var hit_damage: AudioStreamPlayer = $AnimatedSprite2D/hit_damage
@export var floating_label_scene = preload("res://Scenes/control.tscn")

var spawn_position: Vector2
var direction: Vector2 = Vector2.RIGHT
var timer: Timer

# Wing flapping variables
var flap_time: float = 0.0
var base_y: float = 0.0

# --- Chase behavior variables ---
@export var chase_range: float = 400.0  # Distance to start chasing
@export var chase_speed_multiplier: float = 1.3  # How much faster when chasing
@export var lose_target_distance: float = 600.0  # Distance to stop chasing
var is_chasing: bool = false
var chase_direction: Vector2

# --- Patrol ranges (used when not chasing) ---
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
	
	# Timer for random direction changes (only used when not chasing)
	timer = Timer.new()
	timer.wait_time = direction_change_time
	timer.timeout.connect(choose_direction)
	add_child(timer)
	timer.start()
	mob_sfx.play()
		
func _physics_process(delta: float) -> void:
	# Update flapping animation
	flap_time += delta
	var flap_offset = sin(flap_time * flap_speed) * flap_height
	
	# Check if player is in range
	check_player_distance()
	
	# Choose behavior based on chasing state
	if is_chasing:
		chase_player(delta)
	else:
		patrol_behavior(delta)
	
	# Create movement with flapping motion
	var current_speed = CHASE_SPEED if is_chasing else SPEED
	var movement = direction * current_speed
	movement.y += flap_offset * 20  # Add flapping to velocity
	
	linear_velocity = movement
	
	# Always update sprite facing based on current direction
	if direction.x > 0:
		animated_sprite_2d.flip_h = true   # Face right
	elif direction.x < 0:
		animated_sprite_2d.flip_h = false  # Face left

func check_player_distance():
	if not player:
		return
		
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if not is_chasing and distance_to_player <= chase_range:
		# Start chasing
		is_chasing = true
		timer.stop()  # Stop random direction changes
		print("Enemy started chasing player!")
		
	elif is_chasing and distance_to_player >= lose_target_distance:
		# Stop chasing, return to patrol
		is_chasing = false
		timer.start()  # Resume random direction changes
		print("Enemy lost player, returning to patrol")

func chase_player(delta: float):
	if not player:
		return
		
	# Calculate direction to player
	chase_direction = (player.global_position - global_position).normalized()
	
	# Handle obstacle avoidance while chasing
	var avoid_direction = Vector2.ZERO
	
	if ray_right.is_colliding() and chase_direction.x > 0:
		avoid_direction.x -= 1
	if ray_left.is_colliding() and chase_direction.x < 0:
		avoid_direction.x += 1
	if ray_low_right.is_colliding() and chase_direction.x > 0:
		avoid_direction.x -= 1
	if ray_low_left.is_colliding() and chase_direction.x < 0:
		avoid_direction.x += 1
	
	# Blend chase direction with avoidance
	if avoid_direction != Vector2.ZERO:
		direction = (chase_direction + avoid_direction * 0.7).normalized()
	else:
		direction = chase_direction

func patrol_behavior(delta: float):
	# Original patrol logic
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

func choose_direction() -> void:
	# Only change direction randomly when not chasing
	if not is_chasing:
		# Pick a new random direction
		direction = Vector2(
			randf_range(-1, 1),
			randf_range(-0.5, 0.5)
		).normalized()
		
		timer.start()

# Rest of your original script remains the same...
@onready var game_manager = get_node("%GameManager")
var y_delta
var health_decrease_count = 0  # Track how many times health decreased

const killSpot := 50.0

# Add these variables at the top of your script
var can_take_damage: bool = true
var damage_cooldown: float = 1.0  # 1 second cooldown

@onready var animated_sprite_2dplayer = get_node("%Player")

func flash_white():
	# Create a tween for smooth color transition
	var tween = create_tween()
	
	# Flash white briefly
	tween.tween_property(animated_sprite_2dplayer, "modulate", Color.WHITE * 2, 0.1)
	tween.tween_property(animated_sprite_2dplayer, "modulate", Color.WHITE, 0.1)

func _on_area_2d_body_entered(body):
	if (body == player):
		var y_delta = position.y - body.position.y
		
		if (y_delta > killSpot):
			print("Destroy enemy")
			game_manager.add_point()
			spawn_floating_text("+100")
			queue_free() 
			
		elif (y_delta < -killSpot):
			# Player is under the enemy - take damage (with cooldown)
			if can_take_damage:
				print("Decrease player health")
				hit_damage.play()
				player.flash_white()
				
				# Use Game Manager to handle damage
				var is_dead = game_manager.take_damage()
				
				if is_dead:
					print("dead")
					player_death.play()
					await get_tree().create_timer(0.5).timeout
					get_tree().reload_current_scene()
				else:
					# Only start cooldown if player didn't die
					can_take_damage = false
					await get_tree().create_timer(damage_cooldown).timeout
					can_take_damage = true
		else:
			# Side collision - take damage (with cooldown)
			if can_take_damage:
				print("Decrease player health")
				hit_damage.play()
				player.flash_white()
				
				# Use Game Manager to handle damage
				var is_dead = game_manager.take_damage()
				
				if is_dead:
					print("dead")
					player_death.play()
				else:
					# Only start cooldown if player didn't die
					can_take_damage = false
					await get_tree().create_timer(damage_cooldown).timeout
					can_take_damage = true

# Move these functions outside of the collision function
func spawn_floating_text(text: String):
	var label = floating_label_scene.instantiate()
	get_parent().add_child(label)  # Add to the scene
	label.show_text(text, global_position)
