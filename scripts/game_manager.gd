extends Node


var score = 0

@onready var score_label: Label = $ScoreLabel

func add_point():
	score+= 1
	score_label.text = str(score) + " de 7 monedas"
