#WARNING: function might be depracated

extends Area2D

@onready var cooldown: Timer = $Timer  #make sure not needed as physics interp.

#Potentially look into signals?
signal tagged
var on_cooldown:bool = false

#Start our cooldown so the player doesn't immedietly infect (sloppy solution?)
func _ready() -> void:
	cooldown.start()
	on_cooldown = true

func _on_body_entered(body: Node2D) -> void:  #Do we need to check if body is our own?
	if body.isTagger && not on_cooldown:
		body.isTagger = false
		on_cooldown = true
		cooldown.start()
	
	elif not body.isTagger && not on_cooldown:
		body.isTagger = true
		on_cooldown = true
		cooldown.start()

#Function runs when timer runs out
func _on_timer_timeout() -> void:
	#Reset our cooldown conditional
	on_cooldown = false
