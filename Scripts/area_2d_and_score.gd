extends Area2D
class_name StageClearTrigger


# References to UI and audio elements
@onready var stage_cleared_label: Label = $"../Stage_cleared_label"
@onready var stage_cleared_label_2: Label = $"../Stage_cleared_label2"
@onready var clear_sound: AudioStreamPlayer = $"../clear"
@onready var game_manager: Node = $"../GM"
@onready var game: Node = $".."  # Reference to parent node where target_score is located

# Settings
@export var stage_clear_display_time: float = 3.0
@export var fade_in_duration: float = 0.5

# State tracking
var stage_cleared: bool = false
var player_entered_area: bool = false

func _ready():
	_setup_connections()
	_initialize_ui()

func _setup_connections():
	"""Setup signal connections"""
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _initialize_ui():
	"""Initialize UI elements to their starting state"""
	_set_labels_visible(false)

func _set_labels_visible(visible: bool):
	"""Helper function to control label visibility"""
	if stage_cleared_label:
		stage_cleared_label.visible = visible
	if stage_cleared_label_2:
		stage_cleared_label_2.visible = visible

func _process(_delta):
	"""Check for stage clear conditions"""
	if stage_cleared:
		return
		
	if _should_trigger_stage_clear():
		trigger_stage_clear()

func _should_trigger_stage_clear() -> bool:
	"""Check if stage clear conditions are met - BOTH score AND player entry required"""
	var score_reached = game_manager and game and game_manager.score >= game.target_score
	return score_reached and player_entered_area

func _on_body_entered(body: CharacterBody2D) -> void:
	"""Handle player entering the trigger area"""
	if stage_cleared:
		return
		
	if body.is_in_group("player") or body.name.to_lower().contains("player"):
		print("Player entered stage clear area!")
		player_entered_area = true
		
		# Check if we can now trigger stage clear
		if _should_trigger_stage_clear():
			trigger_stage_clear()

func trigger_stage_clear():
	"""Main function to handle stage completion"""
	if stage_cleared:
		return # Prevent multiple triggers
		
	stage_cleared = true
	var current_score = game_manager.score if game_manager else "N/A"
	var required_score = game.target_score if game else "N/A"
	print("Stage cleared! Score: ", current_score, "/", required_score)
	
	_play_clear_sound()
	_show_stage_cleared_ui()
	

func _play_clear_sound():
	"""Play the stage clear sound effect"""
	if clear_sound and clear_sound.stream:
		clear_sound.play()

func _show_stage_cleared_ui():
	"""Display and animate the stage cleared UI"""
	_set_labels_visible(true)
	
	# Animate the labels if they exist
	if stage_cleared_label:
		_animate_label_fade_in(stage_cleared_label)
	if stage_cleared_label_2:
		_animate_label_fade_in(stage_cleared_label_2)

func _animate_label_fade_in(label: Label):
	"""Animate a label fading in"""
	if not label:
		return
		
	label.modulate.a = 0.0
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(label, "modulate:a", 1.0, fade_in_duration)
