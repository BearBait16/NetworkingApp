extends Control

var peer = ENetMultiplayerPeer.new()

@onready var host_port_spin = $OptionContainer/TabContainer/Multiplayer/Host_Port_Spin
@onready var join_port_spin = $OptionContainer/TabContainer/Multiplayer/Join_Port_Spin
@onready var game_mode_option = %GameMode_OptionButton
@onready var speed_spin = $OptionContainer/TabContainer/Multiplayer/SpinBox
@onready var resolution_option_button = %Resolution_Optionbutton
@onready var option_container = get_node("%OptionContainer")
@onready var main_container = get_node("%MainContainer")
@onready var ip_address_field = $OptionContainer/TabContainer/Multiplayer/IpAddress

var game_mode: String

func _get_resolution(index) -> Vector2i:
	var resolution_arr = resolution_option_button.get_item_text(index).split("x")
	return Vector2i(int(resolution_arr[0]), int(resolution_arr[1]))

func _get_game_mode(index) -> String:
	return game_mode_option.get_item_text(index)

func _check_resolution(resolution: Vector2i):
	for i in resolution_option_button.get_item_count():
		if _get_resolution(i) == resolution:
			return i
	return 0  # Default to first resolution

func _load_settings():
	GlobalSettings.load_settings()

	# Apply settings to UI elements
	host_port_spin.value = GlobalSettings.host_port
	join_port_spin.value = GlobalSettings.join_port
	speed_spin.value = GlobalSettings.game_speed
	game_mode = GlobalSettings.game_mode
	get_window().size = GlobalSettings.display_resolution

	# Ensure IP is updated
	ip_address_field.text = GlobalSettings.local_ip

	print("Settings loaded! Resolution:", GlobalSettings.display_resolution)

func _save_settings() -> void:
	var selected_resolution = _get_resolution(resolution_option_button.get_selected_id())

	GlobalSettings.host_port = int(host_port_spin.value)
	GlobalSettings.join_port = int(join_port_spin.value)
	GlobalSettings.display_resolution = selected_resolution
	GlobalSettings.game_speed = speed_spin.value
	GlobalSettings.game_mode = game_mode
	GlobalSettings.save_settings()

	print("Settings saved! Resolution:", selected_resolution)

func _ready():
	_load_settings()
	resolution_option_button.select(_check_resolution(GlobalSettings.display_resolution))

func _on_start_button_pressed():
	if game_mode == "Tag":
		get_tree().change_scene_to_file("res://Scenes/Game.tscn")
	elif game_mode == "Infection":
		get_tree().change_scene_to_file("res://Scenes/Infection.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_option_button_pressed():
	option_container.visible = true
	main_container.visible = false

func _on_exit_button_pressed():
	get_tree().quit()

func _on_return_button_pressed():
	main_container.visible = true
	option_container.visible = false

func _on_apply_button_pressed():
	main_container.visible = true
	option_container.visible = false
	_save_settings()

func _on_resolution_optionbutton_item_selected(index):
	var selected_resolution = _get_resolution(index)
	get_window().size = selected_resolution
	GlobalSettings.display_resolution = selected_resolution

func _on_game_mode_option_button_item_selected(index: int) -> void:
	game_mode = _get_game_mode(index)
	GlobalSettings.game_mode = game_mode

func _on_host_button_pressed() -> void:
	var error = peer.create_server(GlobalSettings.host_port)
	if error == OK:
		multiplayer.multiplayer_peer = peer
		print("Server started on port:", GlobalSettings.host_port)


func _on_join_button_pressed() -> void:
	var ip_to_connect = ip_address_field.text.strip_edges()
	if ip_to_connect.is_empty():
		print("No IP entered! Please provide a valid IP address.")
		return

	var error = peer.create_client(ip_to_connect, GlobalSettings.join_port)
	if error == OK:
		multiplayer.multiplayer_peer = peer
		print("Connected to server at:", ip_to_connect)
	else:
		print("Failed to connect to server. Error:", error)
