extends Node


@onready var game_manager = get_node("%GameManager")
@onready var game_over_label = %GameOverLabel
var target_score : int = 100
var condition : bool

func _ready() -> void:
	game_manager.is_stage_cleared = false 
	game_over_label.visible = false
	
func _process(delta: float) -> void:
	if (condition):
		game_manager.trigger_stage_clear()
