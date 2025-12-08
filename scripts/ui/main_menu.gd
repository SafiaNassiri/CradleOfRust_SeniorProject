extends Control

var audio_manager_scene = preload("res://scenes/UI/main_menu.tscn")

func _ready():
	#var audio_manager = audio_manager_scene.instantiate()
	#get_tree().root.add_child.call_deferred(audio_manager)
	#audio_manager.PROCESS_MODE_WHEN_PAUSED #Process even when paused
	
	#var audioo = get_node("AudioManager/AudioStreamPlayer")
	
	# s button signals
	$VBoxContainer/StartButton.pressed.connect(_press_start)
	#$VBoxContainer/OptionsButton.pressed.connect(_press_options)
	$VBoxContainer/ExitButton.pressed.connect(_press_exit)

# Start button pressed
func _press_start():
	# load game scene
	#audio_manager_scene.play_sound()
	#audioo.play_sound()
	var game_scene = preload("res://scenes/Levels/MainLevel.tscn")
	get_tree().change_scene_to_packed(game_scene)

# Opttions button pressed
#func _press_options():
	## oad options scene
	##audio_manager_scene.play_sound()
	##button_sound.stream = preload("res://assets/ui/Pixel_32.wav")
	##button_sound.play()
	#var options_scene = preload("res://scripts/systems/optionsscene.tscn")
	#get_tree().change_scene_to_packed(options_scene)

# Exit button pressed
func _press_exit():
	#button_sound.stream = preload("res://assets/ui/Pixel_32.wav")
	#button_sound.play()
	get_tree().quit()
	pass
