extends Area2D

@onready var timer = $Timer


func _on_body_entered(body):
	print("You died!")
	if body.get_parent().name == ("Runners"):
		print("Runner Died")
		Engine.time_scale = 0.5
		body.get_node("CollisionShape2D").queue_free()
		timer.start()
	else:
		await get_tree().create_timer(1.5).timeout
		body.respawn()

func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
