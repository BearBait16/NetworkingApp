extends Area2D

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.isTagger:
		body.isTagger = false
	else:
		body.isTagger = true
