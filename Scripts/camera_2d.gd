extends Camera2D

@onready var node_2d: Node2D = $".."
@export var smoothing_speed: float = 5.0

func _physics_process(delta):
	if node_2d:
		var target_x = node_2d.global_position.x
		var new_position = Vector2(
			lerp(global_position.x, target_x, smoothing_speed * delta),
			global_position.y  # lock Y
		)
		global_position = new_position
