extends AnimatedSprite2D

# Size parameters
@export var min_size: float = 0.5
@export var max_size: float = 5.0

# Movement parameters
@export var min_speed: float = 20.0
@export var max_speed: float = 80.0

# Lifetime parameters
@export var min_lifetime: float = 3.0
@export var max_lifetime: float = 6.0

# Screen boundaries
@export var screen_left: float = 0.0
@export var screen_top: float = 0.0
@export var screen_right: float = 1200.0
@export var screen_bottom: float = 750.0

# Internal variables
var speed: float
var lifetime: float
var timer: float = 0.0
var is_faded_out: bool = false
var fade_delay: float = 0.0

func _ready():
	# Set random color modulation
	modulate = Color(
		randf(),  # Random red component (0-1)
		randf(),  # Random green component (0-1)
		randf(),  # Random blue component (0-1)
		1.0       # Full alpha
	)
	
	# Set random size
	var random_scale = randf_range(min_size, max_size)
	scale = Vector2(random_scale, random_scale)
	
	# Set random upward speed
	speed = randf_range(min_speed, max_speed)
	
	# Set random lifetime
	lifetime = randf_range(min_lifetime, max_lifetime)
	
	# Start animation if it has one
	if sprite_frames and sprite_frames.get_animation_names().size() > 0:
		play()

func _process(delta):
	# Move upward
	position.y -= speed * delta
	
	# Track lifetime
	timer += delta
	
	if not is_faded_out:
		# Fade out near end of lifetime
		if timer > lifetime * 0.8:  # Start fading at 80% of lifetime
			var fade_progress = (timer - lifetime * 0.8) / (lifetime * 0.2)
			modulate.a = 1.0 - fade_progress
		
		# Check if completely faded out
		if timer >= lifetime:
			is_faded_out = true
			modulate.a = 0.0
			# Set random delay before respawning
			fade_delay = randf_range(1.0, 3.0)
			timer = 0.0  # Reset timer for fade delay
	else:
		# Handle fade delay and respawn
		if timer >= fade_delay:
			respawn_particle()

func respawn_particle():
	# Reset to new random position within screen bounds
	position.x = randf_range(screen_left, screen_right)
	position.y = randf_range(screen_top, screen_bottom)
	
	# Randomize all properties again
	randomize_properties()
	
	# Reset states
	is_faded_out = false
	timer = 0.0
	
	# Fade in effect
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)

# Optional: Function to randomize everything again
func randomize_properties():
	# Set random color modulation
	modulate = Color(
		randf(),  # Random red component (0-1)
		randf(),  # Random green component (0-1)
		randf(),  # Random blue component (0-1)
		1.0       # Full alpha (will be set properly by fade-in)
	)
	
	# Set random size
	var random_scale = randf_range(min_size, max_size)
	scale = Vector2(random_scale, random_scale)
	
	# Set random upward speed
	speed = randf_range(min_speed, max_speed)
	
	# Set random lifetime
	lifetime = randf_range(min_lifetime, max_lifetime)
