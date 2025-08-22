extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var jump_sfx: AudioStreamPlayer2D = $"jump sfx"
@onready var sprite_2d: Sprite2D = $Sprite2D


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump/flight - can jump from midair
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY
		jump_sfx.play()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction > 0:
		sprite_2d.flip_h = true
	elif direction < 0:
		sprite_2d.flip_h = false
	
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
