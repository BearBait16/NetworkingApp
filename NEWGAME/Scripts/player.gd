extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -350.0

var isTagger = false
@onready var hazmat: AnimatedSprite2D = $Hazmat
@onready var snail: AnimatedSprite2D = $Snail

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("move_left", "move_right")
		
		# determine sprite
		var animated_sprite
		if isTagger:
			animated_sprite = snail
			hazmat.play("Vanish")
		else:
			animated_sprite = hazmat
			snail.play("Vanish")
			
		# flip the sprite
		if direction > 0:
			if isTagger:
				animated_sprite.flip_h = true
			else:
				animated_sprite.flip_h = false
		elif direction < 0:
			if isTagger:
				animated_sprite.flip_h = false
			else:
				animated_sprite.flip_h = true
			
		# play animations
		if is_on_floor():
			if direction == 0:
				if Input.is_action_pressed("down"):
					animated_sprite.play("Down")
				else:
					animated_sprite.play("Idle")
			else:
				animated_sprite.play("Run")
		else:
			animated_sprite.play("Jump")
		
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _enter_tree():
	set_multiplayer_authority(name.to_int())
