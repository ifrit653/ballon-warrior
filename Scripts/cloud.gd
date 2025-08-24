extends GPUParticles2D

func _ready():
	# Create and setup timer
	var timer = Timer.new()
	timer.wait_time = 10.0  # 10 seconds
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	# Emit first particle immediately
	shoot_particle()

func _on_timer_timeout():
	shoot_particle()

func shoot_particle():
	# Generate random direction (360 degrees)
	var angle = randf() * TAU
	var direction = Vector3(cos(angle), sin(angle), 0)
	
	# Set random direction in material
	process_material.direction = direction
	
	# Emit single particle
	amount = 1
	one_shot = true
	emitting = true
	
	print("Particle shot at angle: ", rad_to_deg(angle), " degrees")
