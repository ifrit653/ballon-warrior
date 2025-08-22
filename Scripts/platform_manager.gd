# PlatformManager.gd
extends Node

# References
@onready var player_reference: Node2D = $Player
@onready var ground_map_layer: TileMapLayer = $"../groundMapLayer"	
@onready var platform_manager: Node = $"."
# Platform scene and tracking
var platform_scene = preload("res://Scenes/platform.tscn")  # Your new Platform scene
var active_platforms = []  # Track spawned platforms

var rng := RandomNumberGenerator.new() 

# Generation settings
var spawn_distance_ahead = 800   # Spawn platforms this far above player
var cleanup_distance_behind = 600  # Remove platforms this far below player
var platform_spacing_y = 120    # Vertical gap between platforms
var platform_spacing_x_min = 80  # Minimum horizontal gap
var platform_spacing_x_max = 200 # Maximum horizontal gap

# Tracking
var highest_spawned_y = 0
var screen_width = 0

func _ready():
	rng.randomize() 
	screen_width = get_viewport().size.x

	player_reference = get_node("../../Player")  # Main->Player (adjust if needed)
	
	if player_reference:
		# Start generating platforms above the existing groundMap
		var player_start_y = player_reference.global_position.y
		highest_spawned_y = player_start_y - 200  # Start spawning above current position
		generate_initial_platforms()
	else:
		print("ERROR: Could not find player reference!")

func _process(delta):
	if player_reference:
		check_and_spawn_platforms()
		cleanup_old_platforms()

func check_and_spawn_platforms():
	var player_y = player_reference.global_position.y
	# If player is getting close to highest platform, spawn more
	if player_y <= highest_spawned_y + spawn_distance_ahead:
		spawn_platform_chunk()

func cleanup_old_platforms():
	var player_y = player_reference.global_position.y
	var platforms_to_remove = []
	
	for platform in active_platforms:
		if platform.global_position.y > player_y + cleanup_distance_behind:
			platforms_to_remove.append(platform)
	
	for platform in platforms_to_remove:
		active_platforms.erase(platform)
		platform.queue_free()

func generate_initial_platforms():
	# Generate first set of platforms above existing ground
	for i in range(8):  # Create 8 initial platforms
		spawn_single_platform()

func spawn_platform_chunk():
	# Generate 3-5 platforms at once
	var platforms_to_spawn = rng.randi_range(3, 5)
	for i in range(platforms_to_spawn):
		spawn_single_platform()

func spawn_single_platform():
	var platform = platform_scene.instantiate()
	
	# Random platform type for variety
	var random_type = rng.randi_range(0, 3)
	platform.platform_type = random_type
	
	# Position calculation
	var spawn_y = highest_spawned_y - platform_spacing_y
	var spawn_x = rng.randf_range(100.0, screen_width - 100.0)
	
	platform.global_position = Vector2(spawn_x, spawn_y)
	
	# Add to scene (as sibling to PlatformManager)
	get_parent().add_child(platform)
	active_platforms.append(platform)
	
	# Update highest spawned position
	highest_spawned_y = spawn_y
	
	# Debug info
	print("Spawned platform at: ", platform.global_position, " Type: ", platform.platform_type)
