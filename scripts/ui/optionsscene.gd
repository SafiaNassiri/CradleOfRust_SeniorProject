extends Control

@onready var main_menu_scene: PackedScene = preload("res://scenes/UI/main_menu.tscn")
@onready var player = preload("res://scripts/player/Player.gd").new()

var sound = AudioServer.get_bus_index("Sound")

func _ready():
	$VBoxContainer2/VolumeSlider.value = db_to_linear(sound)
	$VBoxContainer/BackButton.pressed.connect(_press_back)

func _press_back():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(sound, linear_to_db(value))

func _on_brightness_slider_value_changed(value):
	pass
	
	
# might implement control binding

func _up_change(event):
	#up = event.get_scancode_string()
	pass
	
func _left_change():
	pass
	
func _right_change():
	pass
	
func _down_change():
	pass
