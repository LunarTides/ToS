extends Node

var username: String = "Placeholder"
var id: int = 0

@rpc("authority", "call_remote", "reliable")
func assign_id(new_id: int):
	id = new_id
