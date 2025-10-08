extends Node

var score = 0

@onready var score_label: Label = $ScoreLabel
@onready var level = $Level
@onready var game_running: bool = true

func add_point():
	score += 1
	score_label.text = str(score) + " de 7 monedas"


func start_game():
	score = 0

func pause_game():
	if game_running && Input.is_action_just_pressed("pause"):
		$Hud/PauseMenu.show()
		level.get_tree().paused = true
		game_running = false
	elif !game_running && Input.is_action_just_pressed("pause"):
		$Hud/PauseMenu.hide()
		level.get_tree().paused = false
		game_running = true

func _process(_delta: float) -> void:
	pause_game()
