extends Area2D

@onready var game_manager: Node = %Game_Manager

func _on_body_entered(body):
	game_manager.addPoint()
	queue_free()
