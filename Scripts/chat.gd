extends Control

@onready var input = $Panel/LineEdit
@onready var message_container = $Panel/VBoxContainer

@export var max_messages: int

func _on_input_submitted(new_text):
	# Broadcast the text to the server
	add_chat.rpc(User.id, User.username, new_text)
	
	input.text = ""

@rpc("any_peer", "call_local", "unreliable", 1)
func add_chat(player_id: int, player_name: String, text: String):
	# TODO: Save messages to a history
	var messages = message_container.get_children()
	
	# If there is no space, remove the first message
	if messages.size() >= max_messages:
		messages[0].queue_free()
	
	var text_node = RichTextLabel.new()
	
	var prefix = "[color=yellow]%s %s:[/color] " % [player_id, player_name]
	
	if player_id != User.id:
		# If the text contains the user's id or name, make the background color yellow
		var id = str(User.id)
		var containsId = text.begins_with(id) or text.ends_with(id) or text.contains(" %s " % id)

		if containsId or text.to_lower().contains(User.username.to_lower()):
			prefix += "[bgcolor=#cdcd13]"
	else:
		# TODO: REMOVE DEBUG COMMANDS
		if text.begins_with('/debug ability day'):
			var target = int(text.split(" ")[-1])
			target = Lobby.players.values().find(func(player): player.id == target)
			
			Game.use_ability.rpc(target, Game.STAGE.DAY)
		if text.begins_with('/debug ability night'):
			var target = int(text.split(" ")[-1])
			target = Lobby.players.values().find(func(player): player.id == target)
			
			Game.use_ability.rpc(target, Game.STAGE.NIGHT)
		if text.begins_with('/debug role'):
			add_chat.rpc(0, '[SERVER]', 'ROLE: %s' % Game.ROLE.find_key(User.role))
		
		if text == '/debug info':
			add_chat.rpc(0, '[SERVER]', 'GY: %s' % Game.graveyard)
			add_chat.rpc(0, '[SERVER]', 'PLRS: %s' % Lobby.players)
			add_chat.rpc(0, '[SERVER]', 'STAGE: %s' % Game.STAGE.find_key(Game.current_stage))
			add_chat.rpc(0, '[SERVER]', 'LOCALINFO: %s' % Lobby.player_info)
	
	text_node.bbcode_enabled = true
	text_node.text = prefix + text
	text_node.fit_content = true
	
	$Panel/VBoxContainer.add_child(text_node)
