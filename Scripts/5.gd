extends Node2D


func _ready():
	# Wait 4 seconds then change scene
	await get_tree().create_timer(4.0).timeout
	get_tree().change_scene_to_file("res://Scenes/Level_4.tscn")
