extends Node2D

@onready var global_light = $GlobalLight
@onready var player = $Player
@onready var player_light = $Player/PointLight2D

var dark_color = Color(0.1, 0.1, 0.2, 1) 
var bright_color = Color(1, 1, 1, 1)

func _ready():
	# Connect dark room signals
	$DarkRoomArea.body_entered.connect(_on_dark_room_entered)
	$DarkRoomArea.body_exited.connect(_on_dark_room_exited)
	#var bgm = load("res://audio/music/your_track.ogg")
 	#AudioManager.play_music(bgm)

func _on_dark_room_entered(body):
	if body.name == "Player":
		player_light.enabled = true
		var tween = get_tree().create_tween()
		tween.tween_property(global_light, "color", dark_color, 0.5)

func _on_dark_room_exited(body):
	if body.name == "Player":
		var tween = get_tree().create_tween()
		tween.tween_property(global_light, "color", bright_color, 0.5)
		await tween.finished
		player_light.enabled = false
