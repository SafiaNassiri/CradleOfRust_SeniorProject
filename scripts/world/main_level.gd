extends Node2D

@onready var global_light = $GlobalLight
@onready var player = $Player # Make sure this path points to your player node
@onready var player_light = $Player/PointLight2D # Path to the light inside the player

# Standard "Darkness" color (Dark Blue/Grey looks best for sci-fi)
var dark_color = Color(0.1, 0.1, 0.2, 1) 
var bright_color = Color(1, 1, 1, 1)

func _ready():
	# Connect the signals from the Area2D
	$DarkRoomArea.body_entered.connect(_on_dark_room_entered)
	$DarkRoomArea.body_exited.connect(_on_dark_room_exited)

func _on_dark_room_entered(body):
	# Check if it's the player entering
	if body.name == "Player":
		# 1. Turn on the Player's flashlight
		player_light.enabled = true
		
		# 2. Smoothly tween the global light to DARK
		var tween = get_tree().create_tween()
		tween.tween_property(global_light, "color", dark_color, 0.5)

func _on_dark_room_exited(body):
	if body.name == "Player":
		# 1. Smoothly tween the global light back to BRIGHT
		var tween = get_tree().create_tween()
		tween.tween_property(global_light, "color", bright_color, 0.5)
		
		# 2. Turn off the flashlight (wait for the tween to finish so it's not jarring)
		await tween.finished
		player_light.enabled = false
