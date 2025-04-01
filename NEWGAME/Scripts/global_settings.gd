extends Node

var settings_file = ConfigFile.new()

var host_port: int = 135
var join_port: int = 135
var display_resolution: Vector2i = DisplayServer.screen_get_size()
var game_mode: String = "Tag"
var game_speed: float = 1.0
var local_ip: String = ""

const SETTINGS_PATH = "res://settings.cfg" 

func _ready():
	local_ip = get_local_ip()
	load_settings()

func get_local_ip() -> String:
	var addresses = IP.get_local_addresses()
	for ip in addresses:
		if not ip.begins_with("127.") and not ip.contains(":"):
			return ip
	return "Unknown"


func load_settings():
	if settings_file.load(SETTINGS_PATH) != OK:
		print("No settings file found, creating default settings...")
		save_settings() 
	else:
		display_resolution = settings_file.get_value("VIDEO", "Resolution", Vector2i(1024, 768))
		host_port = settings_file.get_value("MULTIPLAYER", "Host_port", 135)
		join_port = settings_file.get_value("MULTIPLAYER", "Join_port", 135)
		game_mode = settings_file.get_value("GAME", "Game_Mode", "Tag")
		game_speed = settings_file.get_value("GAME", "Speed", 1.0)

func save_settings():
	settings_file.set_value("VIDEO", "Resolution", display_resolution)
	settings_file.set_value("MULTIPLAYER", "Host_port", host_port)
	settings_file.set_value("MULTIPLAYER", "Join_port", join_port)
	settings_file.set_value("GAME", "Game_Mode", game_mode)
	settings_file.set_value("GAME", "Speed", game_speed)

	settings_file.save(SETTINGS_PATH)
	print("Settings saved!")
