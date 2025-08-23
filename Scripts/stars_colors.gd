# stars_colors.gd
# Script for AnimatedSprite2D nodes applied at runtime

extends AnimatedSprite2D

# Color array
var colors = [
	Color.PURPLE,
	Color.RED, 
	Color.ORANGE,
	Color.YELLOW,
	Color.WHITE,
	Color.BLUE
]

# Settings
@export var color_change_interval: float = 5.0
@export var rotation_speed: float = 90.0

# Internal variables
var color_timer = 0.0
var rng = RandomNumberGenerator.new()
var initialized = false

func _ready():
	# Check if we can access node properties
	if not initialized:
		initialize_script()

func initialize_script():
	print("Initializing script for: ", name)
	
	# Initialize random generator
	rng.randomize()
	
	# Randomize the initial color timer so stars don't all change at once
	color_timer = rng.randf() * color_change_interval
	
	# Set initial random color
	change_to_random_color()
	
	# Mark as initialized
	initialized = true

func _process(delta):
	# Make sure script is initialized
	if not initialized:
		initialize_script()
		return
	
	# Handle rotation - use rotation instead of rotation_degrees for reliability
	rotation += deg_to_rad(rotation_speed) * delta
	
	# Handle color change timer
	color_timer += delta
	if color_timer >= color_change_interval:
		change_to_random_color()
		color_timer = 0.0

func change_to_random_color():
	if colors.size() == 0:
		return
		
	# Get a random color
	var random_index = rng.randi() % colors.size()
	var new_color = colors[random_index]
	
	# Apply the color
	modulate = new_color
	
	# Optional: Add some randomization to the next color change interval
	color_timer = -rng.randf() * 1.0  # Up to 1 second variation
