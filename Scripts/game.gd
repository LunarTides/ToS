extends Node

@rpc("any_peer", "call_local", "reliable", 0)
func assign_id(id: int):
	User.id = id
	Lobby.player_info.id = id

func start_game():
	pass
