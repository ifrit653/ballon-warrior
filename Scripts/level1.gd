extends Node
 stage_cleared_label
@onready var background: AudioStreamPlayer = $background
@onready var: Label = $Stage_cleared_label
@onready var clear: AudioStreamPlayer = $clear


var targer_score : int = 100
var is_stage_cleared : bool
@export var stage_clear_display_time: float = 3.0  # How long to show "stage cleared"

#refrenee
@onready var game_manager = get_node("%GameManager")

func _ready() -> void:
	is_stage_cleared = false 
	
func trigger_stage_clear():
	is_stage_cleared = true
	
	
	# Play clear sound
	if clear:
		clear.play()
	
	# Show stage cleared label
	if stage_cleared_label:
		stage_cleared_label.visible = true
		
		# Optional: Animate the label appearance
		stage_cleared_label.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(stage_cleared_label, "modulate:a", 1.0, 0.5)
	

	
	# Wait then load next level
	await get_tree().create_timer(stage_clear_display_time).timeout
	load_next_level()


func load_next_level():
	# Load level 3
	get_tree().change_scene_to_file("res://Scenes/titre___level_2.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta : float):
	if (is_stage_cleared == false) and game_manager.score >= targer_score:
		trigger_stage_clear()
