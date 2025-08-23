extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -600.0
@onready var jump_sfx: AudioStreamPlayer2D = $"jump sfx"
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D



func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Play fly animation when not on floor
		if animated_sprite_2d.animation != "fly":
			animated_sprite_2d.play("fly")
	else:
		# Play idle animation when on floor
		if animated_sprite_2d.animation != "idle":
			animated_sprite_2d.play("idle")

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
