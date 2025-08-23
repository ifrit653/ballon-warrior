extends Area2D
@onready var clear: AudioStreamPlayer = $"../clear"
@onready var stage_cleared_label: Label = $"../Stage_cleared_label"

@export var stage_clear_display_time: float = 3.0

var stage_cleared
func _on_body_entered(body: CharacterBody2D) -> void:
	trigger_stage_clear()
	
func trigger_stage_clear():
	stage_cleared = true
	
	
	# Play clear sound
	if clear:
		clear.play()
	
	# Show stage cleared label
	if stage_cleared_label:
		stage_cleared_label.visible = true

	
	# Wait then load next level
	await get_tree().create_timer(stage_clear_display_time).timeout
	load_next_level()


func load_next_level():
	# Load level 3
	get_tree().change_scene_to_file("res://Scenes/titre___level_4.tscn")
