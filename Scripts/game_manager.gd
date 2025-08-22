extends Node
@onready var label: Label = %Label
@onready var score_up: AudioStreamPlayer = $score_up

var score = 0

func add_point():
	score += 100
	print(score)
	label.text = "Score :" + str(score)
	score_up.play()
