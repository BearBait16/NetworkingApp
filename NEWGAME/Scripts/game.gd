#this is game.gd
extends Node

var peer = ENetMultiplayerPeer.new()
@onready var ip_input = $IPLineEdit
@export var player_scene: PackedScene


func _on_host_pressed() -> void:
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
	
func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)
	

#func _on_join_pressed() -> void:
	#peer.create_client("localhost" ,135)
	#multiplayer.multiplayer_peer = peer

func _on_join_pressed() -> void:
	var host_ip = await get_user_input("", "127.0.0.1")  # Prompt user for IP
#	10.244.199.226
	if host_ip == "" or host_ip == null:
		print("No IP provided. Cannot connect.")
		return
		
	print("Connecting to: " + host_ip + ":135")
	peer.create_client(host_ip, 135)  # Connect using the entered IP
	multiplayer.multiplayer_peer = peer

func get_user_input(title: String, placeholder: String) -> String:
	var input_dialog = AcceptDialog.new()
	input_dialog.dialog_text = title
	input_dialog.name = ""
	
	var input_box = LineEdit.new()
	input_box.placeholder_text = placeholder
	input_box.name = "InputBox"
	
	input_box.custom_minimum_size = Vector2(300, 40)  # Width = 300, Height = 30
	
	input_dialog.add_child(input_box)
	add_child(input_dialog)
	
	input_dialog.popup_centered()
	
	await input_dialog.confirmed  # Wait for user to press "OK"
	
	var ip = input_box.text
	input_dialog.queue_free()  # Remove dialog after input
	
	return ip
