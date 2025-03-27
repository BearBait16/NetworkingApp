extends CharacterBody2D

#Define our velocities
const SPEED = 300.0
const JUMP_VELOCITY = -350.0
const G = 9.8  #m/s^2, might be useless

var isTagger = false

#Load our Sprites
@onready var hazmat: AnimatedSprite2D = $Hazmat
@onready var snail: AnimatedSprite2D = $Snail

#Reference our hitbox for info passing to server (IDK if this needed)
@onready var hitbox: CollisionObject2D = $CollisionShape2D

@export var is_local: bool  #Learn exactly what this does
# This allows us to attach a lambda to this player from the main.gd script and call
# it here
@export var on_move: Callable

#Maybe move into _physics_process for more consistent framerate
func _process(delta):  #bro sessions code
	if is_local:
		var direction = Vector2.ZERO
		var moved = false

		#This works only with the other code
		if Input.is_action_pressed("ui_right"):
			direction.x += 1
			moved = true
		if Input.is_action_pressed("ui_left"):
			direction.x -= 1
			moved = true
		if Input.is_action_pressed("ui_down"):
			direction.y += 1
			moved = true
		if Input.is_action_pressed("ui_up"):
			direction.y -= 1
			moved = true

		global_position += direction.normalized() * SPEED * delta
		# Only send our position if it has changed
		if moved:
			on_move.call({
				"x": global_position.x,  #global position refers to pos in ref
				"y": global_position.y   # to game window instead of parent
			})

#Game code
func _physics_process(delta: float) -> void:
	if is_local:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta   #not sure if get gravity works this way

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
