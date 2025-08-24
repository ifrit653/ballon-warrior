extends GPUParticles2D

# Timer for controlling emission intervals
var timer: Timer

func _ready():
	# Setup the particle system
	setup_particles()
	
	# Debug: Check node visibility and camera setup
	print("=== Node Setup Debug ===")
	print("GPUParticles2D visible: ", visible)
	print("GPUParticles2D global position: ", global_position)
	print("GPUParticles2D z_index: ", z_index)
	print("GPUParticles2D modulate: ", modulate)
	
	# Check if we're in a CanvasLayer
	var parent_node = get_parent()
	while parent_node != null:
		if parent_node is CanvasLayer:
			print("Found CanvasLayer parent with layer: ", parent_node.layer)
			break
		parent_node = parent_node.get_parent()
	
	# Create and configure timer
	timer = Timer.new()
	timer.wait_time = 10.0  # 10 seconds
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	
	# Emit first particle immediately (optional)
	emit_single_particle()

func setup_particles():
	# Basic settings - don't override existing material
	emitting = false
	amount = 1
	one_shot = true
	
	# Only modify direction and velocity, keep existing material settings
	if process_material != null:
		var material = process_material as ParticleProcessMaterial
		
		# Only set velocity if not already configured
		if material.initial_velocity_min == 0.0:
			material.initial_velocity_min = 150.0
			material.initial_velocity_max = 300.0
		
		# Small spread for visibility
		material.spread = 15.0
	else:
		print("Warning: No ParticleProcessMaterial found. Please assign one in the inspector.")

func emit_single_particle():
	# Generate random direction (360 degrees)
	var angle = randf() * TAU  # TAU = 2 * PI
	var direction = Vector3(cos(angle), sin(angle), 0)
	
	# Update material with new random direction
	var material = process_material as ParticleProcessMaterial
	material.direction = direction
	
	# Simple approach: just restart with amount = 1
	amount = 1
	one_shot = true
	emitting = true
	
	print("Particle shot at angle: ", rad_to_deg(angle), " degrees")
	print("Settings - Amount: ", amount, " | One Shot: ", one_shot, " | Emitting: ", emitting)

func _on_timer_timeout():
	emit_single_particle()
