extends Node

var latest_id = 0

enum ROLE {
	VIGILANTE,
	VETERAN,
}

enum STAGE {
	DAWN,   # Roles revealed
	DAY,    # Talking
	VOTING, # Voting
	TRIAL,  # Someone on trial
	LYNCH,  # Someone lynched, reveal their role
	DUSK,   # Walking back towards house, voting may skip to this stage if no lynch
	NIGHT,  # Night, night abilities can be used
}

var current_stage = STAGE.DAY

enum DIE_REASON {
	SHOT,
	LYNCHED,
}

# The list of roles to be in the game
var role_list: Array[ROLE] = [
	ROLE.VIGILANTE,
	ROLE.VETERAN,
]

# The possible roles left. Don't change
var possible_roles: Array[ROLE] = role_list

var graveyard = {}

signal lobby_loaded_after_server_disconnected(text: String)

func _ready():
	Lobby.server_disconnected.connect(_on_server_disconnected)

func assign_id(sender_id: int):
	if multiplayer.is_server():
		latest_id += 1
		
		if sender_id == multiplayer.get_unique_id():
			User.assign_id(latest_id)
		else:
			User.assign_id.rpc_id(sender_id, latest_id)

func assign_role(sender_id: int, scrolls: Array[ROLE] = []):
	if multiplayer.is_server():
		# Get the role
		var possible_roles_for_this_user: Array[ROLE] = possible_roles
		
		# Make the scrolls add more chance
		for scroll in scrolls:
			if scroll in possible_roles:
				possible_roles_for_this_user.append(scroll)
		
		var role = possible_roles_for_this_user.pick_random()
		possible_roles.erase(role)
		
		if sender_id == multiplayer.get_unique_id():
			User.assign_role(role)
		else:
			User.assign_role.rpc_id(sender_id, role)

@rpc("any_peer", "call_local", "reliable", 2)
func use_ability(target: User, stage: STAGE):
	var sender_id = multiplayer.get_remote_sender_id()
	var user = Lobby.players[sender_id]
	var role = user.role
	
	if role == ROLE.VIGILANTE:
		if stage == STAGE.NIGHT:
			# Shoot the target
			kill(target, DIE_REASON.SHOT)

func kill(target: User, reason: DIE_REASON):
	Lobby.players.erase(target)
	graveyard[target.id] = {"role": target.role, "reason": reason}
	
	if target.id == User.id:
		# TODO: Make this not quit
		get_tree().quit()

func _on_server_disconnected():
	get_tree().change_scene_to_file("res://Scenes/lobby.tscn")
	
	get_tree().create_timer(0.1).timeout.connect(func(): lobby_loaded_after_server_disconnected.emit("Server Disconnected"))

