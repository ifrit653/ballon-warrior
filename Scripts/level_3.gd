extends Node

# Audio and UI References
@onready var background: AudioStreamPlayer = $background
@onready var stage_cleared_label: Label = $Stage_cleared_label
@onready var clear: AudioStreamPlayer = $clear

# Game Manager Reference
@onready var game_manager: Node = $"Game Manager"

# Game variables
var target_score: float = 400
var stage_cleared: bool

# Settings
@export var stage_clear_display_time: float = 3.0  # How long to show "stage cleared"

func _ready():
	# Hide stage cleared label initially
	if stage_cleared_label:
		stage_cleared_label.visible = false
	stage_cleared = false 
   

func _process(delta):
	if  (stage_cleared == false) and game_manager.score >= target_score:
		print("v")
		trigger_stage_clear()

func trigger_stage_clear():
	stage_cleared = true
	
	
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
	get_tree().change_scene_to_file("res://Scenes/titre___level_3.tscn")
