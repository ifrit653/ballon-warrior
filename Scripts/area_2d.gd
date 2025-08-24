extends Area2D

# References to UI and audio elements
@onready var stage_cleared_label: Label = $"../Stage_cleared_label"
@onready var clear: AudioStreamPlayer = $"../clear"
@onready var stage_cleared_label_2: Label = $"../Stage_cleared_label2"

# Settings
@export var stage_clear_display_time: float = 3.0

# Track if stage has been cleared to prevent multiple triggers
var stage_cleared: bool 

func _ready():
	# Connect the body_entered signal to our function
	body_entered.connect(_on_body_entered)
	
	# Hide stage cleared label initially
	if stage_cleared_label:
		stage_cleared_label.visible = false
	if stage_cleared_label_2:
		stage_cleared_label_2.visible = false

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
	if stage_cleared_label_2:
		stage_cleared_label_2.visible = true
		
		# Animate the label appearance
		stage_cleared_label.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(stage_cleared_label, "modulate:a", 1.0, 0.5)
