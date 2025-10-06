extends Node


var score = 0
var game_running: bool = true

@onready var score_label: Label = $ScoreLabel

func add_point():
	score += 1
	score_label.text = str(score) + " de 7 monedas"


func start_game():
	score = 0
	game_running = true

func pause_game():
	if game_running && Input.is_action_just_pressed("pause"):
		$Hud/PauseMenu.show()
		Engine.time_scale = 0
		game_running = false
	elif !game_running && Input.is_action_just_pressed("pause"):
		$Hud/PauseMenu.hide()
		Engine.time_scale = 1
		game_running = true

func _process(_delta: float) -> void:
	pause_game()
