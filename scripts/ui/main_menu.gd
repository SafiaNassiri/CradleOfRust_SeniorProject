extends Control

@export var button_click_sound: AudioStream  # assign in inspector

func _ready():
	# Connect button signals properly
	$VBoxContainer/StartButton.pressed.connect(Callable(self, "_press_start"))
	$VBoxContainer/ExitButton.pressed.connect(Callable(self, "_press_exit"))

# Start Button
func _press_start():
	# Play click sound
	if button_click_sound:
		AudioManager.play_sfx(button_click_sound)
		
	var game_scene = load("res://scenes/Levels/MainLevel.tscn")
	get_tree().change_scene_to_packed(game_scene)

# Exit Button
func _press_exit():
	if button_click_sound:
		AudioManager.play_sfx(button_click_sound)
	get_tree().quit()
