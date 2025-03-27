extends Node

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

func _on_host_pressed() -> void:
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player(multiplayer.get_unique_id()) 
	
func _add_player(id:int):
	if id == 0: # Prevent adding an invalid player (ChatGPT suggestion)
		print("Failed to add player")
		return 
		
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	
func _on_join_pressed() -> void:
	peer.create_client("10.244.199.226" ,135)
	multiplayer.multiplayer_peer = peer
