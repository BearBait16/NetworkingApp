#NOTE: might need to implement a websocket "scene" alongside this

extends Node

# Capturing this player_scene allows us to instantiate multiple players scenes.
# One for each player that connects to the server
@export var player_scene: PackedScene

# Capture our own player so we know if we've created our own player or not yet
var player_instance

# Creates a new socket client
var socket = WebSocketPeer.new()

# A dictionary for keeping track of all player's information
var players = {}

# When the game is ready we will connect to our websocket server
# we use ws instead of wss because our server is not doing SSL
func _ready():
	socket.connect_to_url("ws://localhost:8080")  #FIX THIS LOCATION
	print("Websocket loaded")

func _process(delta):    #Process vs physics process?
	# In each game loop we poll the socket to see what the current state is
	socket.poll()
	var state = socket.get_ready_state()

	# When the socket's state is open, this is where we handle any incoming messages
	if state == WebSocketPeer.STATE_OPEN:
		# If we haven't created our own player yet we do that now
		# Because this happens once per game loop we need to capture our player
		# instance and null check it so we only create one player
		if player_instance == null:
			player_instance = spawn_self()
		
		# If we have any new incoming messages, this is where they will be processed
		while socket.get_available_packet_count():
			# We know our server will send strings of JSON so we need to parse the
			# message we get from the server as JSON
			var json = JSON.new()
			var error = json.parse(socket.get_packet().get_string_from_utf8())

			if error == OK:
				var data = json.data
				match data.event:
					# for all existing players that we learn about after we join
					# the game, we need to spawn a new player for them
					"existing-players":
						for player in data.players:
							spawn_player(player.playerId, player.position)
					# If someone new joins the server we need to spawn a new player
					# instance for them
					"new-player":
						spawn_player(data.playerId, data.position)
					# every time a player moves we update their position in our local game
					# state
					"player-moved":
						player_moved(data.playerId, data.position)
					# when a player leaves we remove them from our local game state
					"player-left":
						var player = players.get(data.playerId)
						remove_child(player)
						players.erase(data.playerId)
						
			else:
				print(error)
			
	elif state == WebSocketPeer.STATE_CLOSING:
		# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = socket.get_close_code()
		var reason = socket.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.
		
# Update a players position when they have moved
func player_moved(playerId, position):
	players[playerId].rect.global_position = Vector2(position.x, position.y)	
	
# Create our own player object that will move with the up, down, left, right keys
func spawn_self():
	var player = player_scene.instantiate()  # Create an instance
	add_child(player)
	
	# This is the id that all other players will know this player by
	var id = generate_unique_id()  # Add to the scene
	players[id] = player
	
	# Get the screen size
	var screen_size = get_viewport().size

	# Set a random position within the screen bounds
	var random_x = randf_range(50, screen_size.x - 50)  # Adjust margins
	var random_y = randf_range(50, screen_size.y - 50)

	player.position = Vector2(random_x, random_y)
	# This tells the player script that this is the local player that should be moved
	# with the keyboard controls. Without this all players would move when the keys were
	# pressed
	player.is_local = true
	# We set this on_move to a lambda that is called whenever our player moves
	# we then send that information to the server to be rebroadcast out to all players
	player.on_move = func (position):
		var json = JSON.new()
		socket.send_text(json.stringify({
			"event": "player-moved",
			"playerId": id,
			"position": position
		}))
	
	# we join the game to let all other players know our information
	var json = JSON.new()
	socket.send_text(json.stringify({
		"event": "join-game",
		"playerId": id,
		"position": {
			"x": random_x,
			"y": random_y
		}
	}))
	
	return player

# spawns new remote (multiplayer) players
func spawn_player(id, position):
	# If we already know about this player, don't bother recreating it
	if players.get(id) != null:
		return

	var player = player_scene.instantiate()  # Create an instance
	add_child(player)  # Add to the scene
	players[id] = player

	player.position = Vector2(position.x, position.y)
	# so keyboard controls don't work
	player.is_local = false
	# we also don't set on_move here because they are a remote player. They will tell us
	# when they move, we don't want to try to rebroadcast other players positions.
	
	return player
	
func generate_unique_id():
	return str(hash(str(Time.get_unix_time_from_system(), "_", Time.get_ticks_usec())))
