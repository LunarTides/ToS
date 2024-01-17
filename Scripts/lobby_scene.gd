extends Control

# TODO: Remove this
var host_button_times = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_host_button_pressed():
	# Create server.
	update_player()
	
	if host_button_times == 0:
		Lobby.create_game()
	else:
		Lobby.load_game.rpc("res://Scenes/chat.tscn")
	
	host_button_times += 1


func _on_connect_button_pressed():
	# Create client.
	update_player()
	Lobby.join_game($Inputs/IPInput.text)

func update_player():
	User.username = $Inputs/NameInput.text
	
	Lobby.player_info.username = User.username
	Lobby.player_info.id = User.id
