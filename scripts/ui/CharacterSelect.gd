extends Control

func _ready():
	$Male.pressed.connect(func(): _select_character("male"))
	$Female.pressed.connect(func(): _select_character("female"))

func _select_character(gender):
	var save_data = {"gender": gender}
	var file = FileAccess.open("user://prefs.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	get_tree().change_scene_to_file("res://scenes/TestLevel.tscn")
