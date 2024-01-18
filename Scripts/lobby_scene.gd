extends Control

# TODO: Remove this
var host_button_times = 0

@onready var connect_button = $Buttons/ConnectButton
@onready var host_button = $Buttons/HostButton

@onready var ip_input = $Inputs/IPInput
@onready var name_input = $Inputs/NameInput

@onready var texts = $Text
@onready var wait_text = $Text/Wait
@onready var players_text = $Text/Players

@onready var info_popup = $InfoPopup

# Called when the node enters the scene tree for the first time.
func _ready():
	Lobby.player_connected.connect(update_players_label)
	Game.lobby_loaded_after_server_disconnected.connect(popup)

func _on_host_button_pressed():
	# Create server.
	update_player()
	
	if host_button_times == 0:
		Lobby.create_game()
	else:
		Lobby.load_game.rpc("res://Scenes/chat.tscn")
	
	host_button_times += 1
	
	disable_buttons_and_inputs()
	host_button.text = "Start Game"
	host_button.disabled = false
	
	wait_text.visible = false
	update_labels()


func _on_connect_button_pressed():
	# Create client.
	update_player()
	Lobby.join_game(ip_input.text)
	
	disable_buttons_and_inputs()
	update_labels()

func update_player():
	User.username = name_input.text
	
	Lobby.player_info.username = User.username
	Lobby.player_info.id = User.id

func disable_buttons_and_inputs():
	connect_button.disabled = true
	host_button.disabled = true
	
	ip_input.editable = false
	name_input.editable = false

func update_labels():
	texts.visible = true
	update_players_label(null, null)

func update_players_label(_peer_id, _player_info):
	players_text.text = "Players Connected: %s" % Lobby.players_loaded

func popup(text):
	info_popup.visible = true
	info_popup.set_item_text(0, text)
