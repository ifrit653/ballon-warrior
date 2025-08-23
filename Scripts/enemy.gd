extends RigidBody2D
@onready var player: CharacterBody2D = $"../../Node2D"

const SPEED := 150.0

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
	mob_sfx.play()
		
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
		animated_sprite_2d.flip_h = true   # Face right
	elif direction.x < 0:
		animated_sprite_2d.flip_h = false  # Face left

func choose_direction() -> void:
	# Pick a new random direction
	direction = Vector2(
		randf_range(-1, 1),
		randf_range(-0.5, 0.5)
	).normalized()
	
	timer.start()

@onready var game_manager: Node = %"Game Manager"
var y_delta
var health_decrease_count = 0  # Track how many times health decreased

const killSpot := 50.0

# Add these variables at the top of your script
var can_take_damage: bool = true
var damage_cooldown: float = 1.0  # 1 second cooldown

@onready var animated_sprite_2dplayer: AnimatedSprite2D = $"../../Node2D"/AnimatedSprite2D

func flash_white():
	# Create a tween for smooth color transition
	var tween = create_tween()
	
	# Flash white briefly
	tween.tween_property(animated_sprite_2dplayer, "modulate", Color.WHITE * 2, 0.1)
	tween.tween_property(animated_sprite_2dplayer, "modulate", Color.WHITE, 0.1)

func _on_area_2d_body_entered(body):
	if (body == player):
		y_delta = position.y - body.position.y
		
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
