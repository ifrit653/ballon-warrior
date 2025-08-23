# Alternative approach: Manage all stars from the parent script
# This avoids the runtime script application issues

extends Node

# Colors array
var colors = [
	Color.PURPLE,
	Color.ORANGE,
	Color.YELLOW,
	Color.WHITE,
]

# All your star references
@onready var stars = [
	$star1, $star2, $star3, $star4, $star5,
	$star6, $star7, $star8, $star9, $star10,
	$star11, $star12, $star13, $star14, $star15,
	$star16, $star17, $star18, $star19, $star20
]

# Individual timers and settings for each star
var star_data = []
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	
	# Initialize data for each star
	for i in range(stars.size()):
		star_data.append({
			"color_timer": rng.randf() * 5.0,  # Random start time
			"color_interval": 5.0,
			"rotation_speed": 140.0 + rng.randf() * 60.0,  # 90-150 degrees/sec
			"star": stars[i]
		})
		
		# Set initial random color
		set_random_color(i)
	
	print("Initialized ", stars.size(), " stars")

func _process(delta):
	# Update each star individually
	for i in range(star_data.size()):
		var data = star_data[i]
		var star = data.star
		
		if not star:
			continue
			
		# Handle rotation
		star.rotation_degrees += data.rotation_speed * delta
		
		# Handle color change
		data.color_timer += delta
		if data.color_timer >= data.color_interval:
			set_random_color(i)
			data.color_timer = 0.0

func set_random_color(star_index: int):
	if star_index >= star_data.size():
		return
		
	var star = star_data[star_index].star
	if not star:
		return
		
	var random_index = rng.randi() % colors.size()
	star.modulate = colors[random_index]
