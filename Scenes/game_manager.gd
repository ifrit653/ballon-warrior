extends Node
@onready var label: Label = %Label

var score = 0

func add_point():
	score += 100
	print(score)
	label.text = "Score :" + str(score)
