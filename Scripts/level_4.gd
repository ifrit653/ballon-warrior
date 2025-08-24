extends Node

@export var target_score: float = 500.0
@export var stage_clear_display_time: float = 3.0

func _process(delta):
	pass 

func trigger_stage_clear():
	# Wait then load next level
	await get_tree().create_timer(stage_clear_display_time).timeout
	load_next_level()

func load_next_level():
	# Load level 3 (same as your original script)
	get_tree().change_scene_to_file("res://Scenes/titre_level_5.tscn")
