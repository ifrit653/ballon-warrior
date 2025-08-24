extends Area2D

# References to UI and audio elements
@onready var stage_cleared_label: Label = $"../Stage_cleared_label"
@onready var clear: AudioStreamPlayer = $"../clear"

# Settings
@export var stage_clear_display_time: float = 3.0

# Track if stage has been cleared to prevent multiple triggers
var stage_cleared: bool 

func _ready() -> void:
	# Hide stage cleared label initially
	if stage_cleared_label:
		stage_cleared_label.visible = false

	# Connect the signal properly
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: CharacterBody2D) -> void:
	if stage_cleared:
		return # Prevent multiple triggers
		
	print("CharacterBody2D entered area - triggering stage clear!")
	trigger_stage_clear()

func trigger_stage_clear():
	stage_cleared = true
	
	# Play clear sound
	if clear:
		clear.play()
	
	# Show stage cleared label
	if stage_cleared_label:
		stage_cleared_label.visible = true
		
		# Animate the label appearance
		stage_cleared_label.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(stage_cleared_label, "modulate:a", 1.0, 0.5)

# Wait then load next level
	await get_tree().create_timer(stage_clear_display_time).timeout
	load_next_level()

func load_next_level():
	# Load level 3 (same as your original script)
	get_tree().change_scene_to_file("res://Scenes/titre_level_4.tscn")
