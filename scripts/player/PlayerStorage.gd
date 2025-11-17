extends Node

# Path to save file
const SAVE_PATH := "user://player_save.json"

# Save player data
func save(player_node: Node) -> void:
	var data: Dictionary = {
		"inventory": player_node.inventory,
		"stats": {
			"scrap": player_node.stats.scrap,
			"stamina": player_node.stats.stamina
		},
		"position": player_node.global_position
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("💾 Player data saved.")

# Load player data
func load(player_node: Node) -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("⚠️ No save file found.")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var result = JSON.parse_string(file.get_as_text())
	file.close()

	if result.error != OK:
		print("⚠️ Failed to parse save file.")
		return
	
	var data: Dictionary = result.result  # explicitly typed

	if data.has("inventory"):
		player_node.inventory = data.inventory.duplicate()
	if data.has("stats"):
		if data.stats.has("scrap"):
			player_node.stats.scrap = data.stats.scrap
		if data.stats.has("stamina"):
			player_node.stats.stamina = data.stats.stamina
	if data.has("position"):
		player_node.global_position = data.position
	print("✅ Player data loaded.")
