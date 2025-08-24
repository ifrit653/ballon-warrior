extends Area2D
class_name KillZone


@onready var timer: Timer = $Timer
@onready var player : Player= get_node("%Player")
@onready var game_manager = %GameManager 

func _ready():
	pass 

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		game_manager.handle_game_over()
		print("enter kill zone")
func _on_timer_timeout() -> void:
	get_tree().reload_current_scene() 
 
