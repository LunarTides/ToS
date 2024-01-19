extends Node

var username: String = "Placeholder"
var id: int = 0
var role: Game.ROLE

@rpc("authority", "call_remote", "reliable")
func assign_id(new_id: int):
	id = new_id

@rpc("authority", "call_remote", "reliable")
func assign_role(new_role: Game.ROLE):
	role = new_role
	
