extends Node

@export var player_scene: PackedScene  # PackedScene for spawning players

var player_instance
var socket = WebSocketPeer.new()
var players = {}

func _ready():
	# Connect to your WebSocket server
	print("working!")
	socket.connect_to_url("ws://localhost:8081") 
	 # Change this if needed

func _process(delta):
	socket.poll()
	var state = socket.get_ready_state()

	if state == WebSocketPeer.STATE_OPEN:
		if player_instance == null:
			player_instance = spawn_self()
		
		while socket.get_available_packet_count():
			var json = JSON.new()
			var error = json.parse(socket.get_packet().get_string_from_utf8())

			if error == OK:
				var data = json.data
				match data.event:
					"existing-players":
						for player in data.players:
							spawn_player(player.playerId, player.position)
					"new-player":
						spawn_player(data.playerId, data.position)
					"player-moved":
						player_moved(data.playerId, data.position)
					"player-left":
						remove_player(data.playerId)
			else:
				print("JSON Parse Error:", error)

	elif state == WebSocketPeer.STATE_CLOSED:
		print("WebSocket disconnected:", socket.get_close_code(), socket.get_close_reason())
		set_process(false)

func player_moved(playerId, position):
	if players.has(playerId):
		players[playerId].global_position = Vector2(position.x, position.y)

func spawn_self():
	var player = player_scene.instantiate()
	add_child(player)

	var id = generate_unique_id()
	players[id] = player

	var screen_size = get_viewport().size
	var random_x = randf_range(50, screen_size.x - 50)
	var random_y = randf_range(50, screen_size.y - 50)

	player.position = Vector2(random_x, random_y)
	player.is_local = true

	player.on_move = func(position):
		var json = JSON.new()
		socket.send_text(json.stringify({
			"event": "player-moved",
			"playerId": id,
			"position": position
		}))

	socket.send_text(JSON.new().stringify({
		"event": "join-game",
		"playerId": id,
		"position": { "x": random_x, "y": random_y }
	}))

	return player

func spawn_player(id, position):
	if players.has(id):
		return

	var player = player_scene.instantiate()
	add_child(player)
	players[id] = player
	player.position = Vector2(position.x, position.y)
	player.is_local = false

func remove_player(id):
	if players.has(id):
		players[id].queue_free()
		players.erase(id)

func generate_unique_id():
	return str(hash(str(Time.get_unix_time_from_system(), "_", Time.get_ticks_usec())))
