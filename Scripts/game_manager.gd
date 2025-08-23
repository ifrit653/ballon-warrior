extends Node
@onready var label: Label = %Label
@onready var score_up: AudioStreamPlayer = $score_up


var score : int
func _ready() -> void:
	score = 0


func add_point():
	score += 100
	print(score)
	label.text = "Score :" + str(score)
	score_up.play()
	print(score)
	return score

# Add these variables to your Game Manager
var player_health = 2  # Starting health
var max_health = 2

# Function to handle player taking damage
func take_damage():
	player_health -= 1
	print("Player health: ", player_health)
	
	if player_health <= 0:
		return true  # Player is dead
	return false  # Player is still alive

# Optional: Function to reset health (for new game/respawn)
func reset_health():
	player_health = max_health
	
