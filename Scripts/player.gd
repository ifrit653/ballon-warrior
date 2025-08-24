extends CharacterBody2D
class_name Player

const SPEED = 200.0
const JUMP_VELOCITY = -600.0
const DEATH_FALL_SPEED = 300.0  # Initial fall speed
const DEATH_GRAVITY_MULTIPLIER = 0.5  # Slower gravity during death

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: Node = %"GM"
@onready var jump_sfx: AudioStreamPlayer2D = $"jump sfx"

@export var screen_width: float = 1024  # width of your viewport
@export var screen_height: float = 600  # height of your viewport

var is_dead = false
var death_timer = 0.0
var has_fallen_off_screen = false
const DEATH_RESTART_DELAY = 2.0

func _physics_process(delta: float) -> void:
	# Check for death state
	if game_manager.player_health <= 0 and not is_dead:
		start_death_sequence()
		return
	
	# If dead, handle death physics
	if is_dead:
		handle_death_physics(delta)
		return
	
	# Normal gameplay physics (only when alive)
	handle_normal_physics(delta)

func handle_normal_physics(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Handle all 4 animation possibilities
	if is_on_floor() and game_manager.player_health == 2:
		# On floor with full health
		if animated_sprite_2d.animation != "idle":
			animated_sprite_2d.play("idle")
	elif is_on_floor() and game_manager.player_health == 1:
		# On floor with low health
		if animated_sprite_2d.animation != "1up_idle":
			animated_sprite_2d.play("1up_idle")
	elif not is_on_floor() and game_manager.player_health == 2:
		# In air with full health
		if animated_sprite_2d.animation != "fly":
			animated_sprite_2d.play("fly")
	elif not is_on_floor() and game_manager.player_health == 1:
		# In air with low health
		if animated_sprite_2d.animation != "1up_fly":
			animated_sprite_2d.play("1up_fly")
	
	# Handle jump/flight - can jump from midair
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY
		jump_sfx.play()
	
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction > 0:
		animated_sprite_2d.flip_h = false
	elif direction < 0:
		animated_sprite_2d.flip_h = true
	
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

func start_death_sequence():
	is_dead = true
	death_timer = 0.0
	has_fallen_off_screen = false
	
	# Play death animation
	animated_sprite_2d.play("death")
	
	# Disable collision detection
	set_collision_layer(0)
	set_collision_mask(0)
	
	# Set initial death velocity (moderate downward speed)
	velocity.y = DEATH_FALL_SPEED
	velocity.x = 0  # Stop horizontal movement

func handle_death_physics(delta: float) -> void:
	# Apply reduced gravity for a more dramatic fall
	velocity.y += get_gravity().y * delta * DEATH_GRAVITY_MULTIPLIER
	
	# Keep horizontal movement at zero during death
	velocity.x = 0
	
	# Move without collision detection
	position += velocity * delta
	
	# Check if player has fallen well below screen (more generous distance)
	if position.y > screen_height + 200 and not has_fallen_off_screen:
		has_fallen_off_screen = true
		death_timer = 0.0  # Reset timer when player falls off screen
	
	# Only start countdown after falling off screen
	if has_fallen_off_screen:
		death_timer += delta
		
		# Check if enough time has passed to restart
		if death_timer >= DEATH_RESTART_DELAY:
			restart_game()

func restart_game():
	# Reset death state
	is_dead = false
	death_timer = 0.0
	has_fallen_off_screen = false
	
	# Re-enable collision detection
	set_collision_layer(1)  # Adjust layer numbers as needed
	set_collision_mask(1)   # Adjust mask numbers as needed
	
	# Reset velocity
	velocity = Vector2.ZERO
	
	# You can either:
	# 1. Reload the current scene
	get_tree().reload_current_scene()
	
	# 2. Or call a game manager restart function
	# if game_manager.has_method("restart_game"):
	#     game_manager.restart_game()

func _process(delta):
	# Only do screen wrapping when alive
	if not is_dead:
		# Horizontal wrap
		if position.x > screen_width:
			position.x = 0
		elif position.x < 0:
			position.x = screen_width

func flash_white():
	# Only flash if not dead
	if is_dead:
		return
		
	# Create a tween for smooth color transition
	var tween = create_tween()
	
	# Flash white briefly
	tween.tween_property(animated_sprite_2d, "modulate", Color.WHITE * 2, 0.1)
	tween.tween_property(animated_sprite_2d, "modulate", Color.WHITE, 0.1)
