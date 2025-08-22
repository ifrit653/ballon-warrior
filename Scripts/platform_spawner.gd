extends Node2D

@export var platform_scene: PackedScene
@export var spawn_distance_ahead: float = 600
@export var cleanup_distance: float = 600

@onready var player: Node2D = $"../Player"
var active_platforms: Array = []
var current_y: float  
var screen_width: float
var pattern_index: int = 0

# Define platform patterns
var platform_patterns = [
	# Pattern 1: Normal progression
	[
		{"type": 0, "x_percent": 0.2, "gap_y": 120},  # NORMAL at 20% screen width
		{"type": 1, "x_percent": 0.5, "gap_y": 130},  # WIDE at 70% screen width
		{"type": 2, "x_percent": 0.4, "gap_y": 110},  # NARROW at 40% screen width
	],
	# Pattern 2: Wide gaps
	[
		{"type": 0, "x_percent": 0.15, "gap_y": 150},
		{"type": 0, "x_percent": 0.85, "gap_y": 140},
		{"type": 1, "x_percent": 0.5, "gap_y": 120},
	],
	# Pattern 3: Challenging
	[
		{"type": 2, "x_percent": 0.3, "gap_y": 160},   # NARROW
		{"type": 2, "x_percent": 0.8, "gap_y": 140},   # NARROW
		{"type": 3, "x_percent": 0.1, "gap_y": 120},   # BREAKABLE
		{"type": 1, "x_percent": 0.6, "gap_y": 130},   # WIDE (safe landing)
	],
	# Pattern 4: Mixed
	[
		{"type": 1, "x_percent": 0.25, "gap_y": 100},  # WIDE
		{"type": 0, "x_percent": 0.75, "gap_y": 120},  # NORMAL
		{"type": 2, "x_percent": 0.5, "gap_y": 140},   # NARROW
	]
]

func _ready():
	screen_width = get_viewport().size.x
	current_y = player.global_position.y - 200
	generate_initial_platforms()

func _process(delta):
	if player.global_position.y <= current_y + spawn_distance_ahead:
		spawn_pattern_chunk()
	cleanup_old_platforms()

func generate_initial_platforms():
	# Generate 2 patterns to start
	spawn_pattern_chunk()
	spawn_pattern_chunk()

func spawn_pattern_chunk():
	var current_pattern = platform_patterns[pattern_index]
	
	print("Spawning pattern: ", pattern_index, " with ", current_pattern.size(), " platforms")
	
	for platform_data in current_pattern:
		spawn_single_platform(platform_data)
	
	# Move to next pattern
	pattern_index = (pattern_index + 1) % platform_patterns.size()

func spawn_single_platform(platform_data: Dictionary):
	var platform = platform_scene.instantiate() as Platform
	
	# Set platform type from pattern
	platform.platform_type = platform_data["type"]
	
	# Calculate position from pattern
	var x = screen_width * platform_data["x_percent"]
	current_y -= platform_data["gap_y"]
	
	platform.global_position = Vector2(x, current_y)
	add_child(platform)
	active_platforms.append(platform)
	
	print("Spawned platform type ", platform.platform_type, " at ", platform.global_position)

func cleanup_old_platforms():
	var player_y = player.global_position.y
	for p in active_platforms.duplicate():
		if p.global_position.y > player_y + cleanup_distance:
			active_platforms.erase(p)
			p.queue_free()
