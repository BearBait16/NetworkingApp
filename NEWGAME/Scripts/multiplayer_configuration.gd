extends Node

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
var has_no_player = true

func _ready():
	if multiplayer.multiplayer_peer:  
		if multiplayer.is_server():
			print("Hosting detected, adding player...")
			_add_player(multiplayer.get_unique_id())
		elif multiplayer.is_client():
			print("Client detected, adding player...")
			_add_player(multiplayer.get_unique_id())

func _on_host_pressed() -> void:
	var error = peer.create_server(GlobalSettings.host_port)
	if error == OK:
		multiplayer.multiplayer_peer = peer
		print("Hosting server on port", GlobalSettings.host_port)
		multiplayer.peer_connected.connect(_on_peer_connected)
		_add_player(multiplayer.get_unique_id())
	else:
		print("Failed to host server. Error:", error)

func _on_join_pressed() -> void:
	var error = peer.create_client(GlobalSettings.local_ip, GlobalSettings.join_port)
	if error == OK:
		multiplayer.multiplayer_peer = peer
		print("Joining server at ", GlobalSettings.local_ip)
	else:
		print("Failed to join server. Error:", error)

func _on_peer_connected(peer_id: int):
	print("New peer connected: ", peer_id)
	_add_player(peer_id)

func _add_player(id: int):
	if has_no_player:
		if id == 0: # Prevent adding an invalid player
			print("Failed to add player, invalid ID")
			return 
		
		var player = player_scene.instantiate()
		player.name = str(id)
		call_deferred("add_child", player)
		print("Player added with ID:", id)
		has_no_player = false
