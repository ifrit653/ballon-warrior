extends Node
class_name GameManager 

#references
@onready var score_up: AudioStreamPlayer = $score_up
@onready var stage_cleared_label : Label = $Stage_cleared_label
@onready var player : Player = %Player
@onready var background: AudioStreamPlayer = $background
@onready var clear: AudioStreamPlayer = $clear
@onready var game_over_label = %GameOverLabel
@onready var score_label := %ScoreLabel 

var score : int = 0
var is_stage_cleared : bool
var game_state_list = ['over','play', "pause", "win"]
var game_state : String = "play"

func restart_game():
	await get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()

func handle_game_state(state: String):
	match state: 
		"win":
			game_state = "win"
		"over":
			game_state = "over"
		"pause":
			game_state = "pause"
#public func
func handle_game_over():
	if not player.is_dead: 
		return
	handle_game_state("over")
	print("game over")
	player.is_dead = true  
	if game_over_label:
		game_over_label.visible = true
	else:
		print("could not retrieve killzone game over label")
		player.start_death_sequence()
	restart_game()
	

func load_next_level():
	pass 
 
func trigger_stage_clear():
	handle_game_state("win")
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
	

	

	#await get_tree().create_timer(stage_clear_display_time).timeout
	load_next_level()



func add_point():
	score += 100
	score_label.text = "Score :" + str(score)
	score_up.play()
	return score

# Function to handle player taking damage
func take_damage():
	player.player_health -= 1
	print("Player health: ", player.player_health)
	
	if player.player_health <= 0:
		player.is_dead = true
		handle_game_over()
	else: 
		return 
