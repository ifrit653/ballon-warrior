extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -600.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: Node = $"..//Game Manager"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $AnimatedSprite2D/Sprite2D
@onready var jump_sfx: AudioStreamPlayer2D = $"jump sfx"

func _physics_process(delta: float) -> void:
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
	elif game_manager.player_health == 0:
		animated_sprite_2d.play("death")
		set_collision_mask_value(1, false)  # Disable collision with layer 1 (adjust layer number as needed)
		# Apply gravity and make player fall
		velocity.x = 0  # Stop horizontal movement
		velocity.y += get_gravity().y * delta  # Apply gravity
		# Move without collision detection
		position += velocity * delta
		
		# Optional: Connect to animation finished signal for cleanup
		if not animation_player.animation_finished.is_connected(_on_death_animation_finished):
			animation_player.animation_finished.connect(_on_death_animation_finished)

func _on_death_animation_finished(anim_name: StringName):
	if anim_name == "death":
		# Handle what happens after death animation (reload scene, etc.)
		get_tree().reload_current_scene()

	# Handle jump/flight - can jump from midair
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY
		jump_sfx.play()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
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
	
@export var screen_width: float = 1024  # width of your viewport
@export var screen_height: float = 600  # height of your viewport

func _process(delta):
	# Example: horizontal wrap
	if position.x > screen_width:
		position.x = 0
	elif position.x < 0:
		position.x = screen_width

func flash_white():
	# Create a tween for smooth color transition
	var tween = create_tween()
	
	# Flash white briefly
	tween.tween_property(animated_sprite_2d, "modulate", Color.WHITE * 2, 0.1)
	tween.tween_property(animated_sprite_2d, "modulate", Color.WHITE, 0.1)
