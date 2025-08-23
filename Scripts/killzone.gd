extends Area2D

@onready var timer: Timer = $Timer
@onready var game_over_label: Label = $Label

func _ready():
	# Hide the game over label at start
	if game_over_label:
		game_over_label.visible = false

func _on_body_entered(body: Node2D) -> void:
	# Only proceed if it's a CharacterBody2D
	if body is CharacterBody2D:
		# Show game over label
		if game_over_label:
			game_over_label.visible = true
		
		# Start 3-second timer for restart
		timer.wait_time = 3.0
		timer.start()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
