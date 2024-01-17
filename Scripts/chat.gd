extends Control

@onready var input = $Panel/LineEdit
@export var max_messages: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_input_submitted(new_text):
	# Broadcast the text to the server
	add_chat.rpc(User.id, User.username, new_text)
	
	$Panel/LineEdit.text = ""

@rpc("any_peer", "call_local", "unreliable", 1)
func add_chat(player_id: int, player_name: String, text: String):
	# TODO: Update existing element if no space
	var messages = $Panel/VBoxContainer.get_children()
	
	if messages.size() >= max_messages:
		messages[0].queue_free()
	
	var text_node = RichTextLabel.new()
	
	var prefix = "[color=yellow]" + str(player_id) + " " + player_name + ":[/color] "
	
	if player_id != User.id:
		# If the text contains the user's id or name, make the background color yellow
		if text.contains(str(User.id)) or text.to_lower().contains(User.username.to_lower()):
			prefix += "[bgcolor=#cdcd13]"
	
	text_node.bbcode_enabled = true
	text_node.text = prefix + text
	text_node.fit_content = true
	
	$Panel/VBoxContainer.add_child(text_node)
