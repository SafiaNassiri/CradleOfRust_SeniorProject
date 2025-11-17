extends Node

const SAVE_PATH := "user://player_save.json"

# Save player data
func save(player_node: Node) -> void:
	var data: Dictionary = {
		"inventory": player_node.inventory,
		"stats": {
			"scrap": player_node.stats.scrap,
			"stamina": player_node.stats.stamina
		},
		# Save position as array [x, y] for JSON
		"position": [player_node.global_position.x, player_node.global_position.y]
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("Player data saved.")


# Load player data
func load(player_node: Node) -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found.")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var text = file.get_as_text()
	file.close()

	var data: Dictionary = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		print("Failed to parse save file.")
		return

	if data.has("inventory"):
		player_node.inventory = data.inventory.duplicate()
	if data.has("stats"):
		if data.stats.has("scrap"):
			player_node.stats.scrap = data.stats.scrap
		if data.stats.has("stamina"):
			player_node.stats.stamina = data.stats.stamina
	if data.has("position"):
		var pos_array = data.position
		if typeof(pos_array) == TYPE_ARRAY and pos_array.size() == 2:
			player_node.global_position = Vector2(pos_array[0], pos_array[1])
	print("Player data loaded.")
