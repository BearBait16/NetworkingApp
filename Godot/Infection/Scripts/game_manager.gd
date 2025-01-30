extends Node

var score = 0

@onready var score_label: Label = $"../ScoreLabel"


func addPoint():
	score+=1
	score_label.text = "Coins x " + str(score)
