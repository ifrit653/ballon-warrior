extends Node2D


@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# The scene to load after the delay
@export var target_scene: String = "res://Scenes/your_scene.tscn"

func _ready():
	# Wait 4 seconds then change scene
	await get_tree().create_timer(4.0).timeout
	get_tree().change_scene_to_file("res://Scenes/Level 3.tscn")
