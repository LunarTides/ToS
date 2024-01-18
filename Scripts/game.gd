extends Node

var latest_id = 0

signal lobby_loaded_after_server_disconnected(text: String)

func _ready():
	Lobby.server_disconnected.connect(_on_server_disconnected)

func assign_id(sender_id: int):
	if multiplayer.is_server():
		latest_id += 1
		
		if sender_id == multiplayer.get_unique_id():
			User.assign_id(sender_id)
		else:
			User.assign_id.rpc_id(sender_id, latest_id)

func start_game():
	pass

func _on_server_disconnected():
	get_tree().change_scene_to_file("res://Scenes/lobby.tscn")
	
	get_tree().create_timer(0.1).timeout.connect(func(): lobby_loaded_after_server_disconnected.emit("Server Disconnected"))

