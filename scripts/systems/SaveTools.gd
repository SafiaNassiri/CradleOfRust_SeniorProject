extends Node

static func wipe_all_saves():
	var files = [
		"user://prefs.json",
		"user://player_save.json",
		"user://resources.json",
		"user://inventory.json",
		"user://system_data.json"
	]

	for f in files:
		if FileAccess.file_exists(f):
			DirAccess.remove_absolute(f)
			print("Deleted:", f)

	print("All save data wiped!")

	# Auto-restart the game
	_restart_game()

static func _restart_game():
	# Get SceneTree properly typed
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if not tree:
		push_error("Failed to get SceneTree!")
		return
	
	print("Restarting game after wipe...")
	tree.reload_current_scene()
