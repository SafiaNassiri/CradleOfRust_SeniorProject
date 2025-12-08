extends Node

const SAVE_PATH := "user://player_save.json"

func save(player):
	var data: Dictionary = {
		"inventory": Inventory.inventory_slots,
		"stats": {
			"scrap": player.stats.scrap,
			"stamina": player.stats.stamina
		}
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("Saved.")

func load(player):
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file. Using scene editor position.")
		return false  # do nothing, keep player where it is in the scene

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if typeof(data) != TYPE_DICTIONARY:
		print("Save invalid. Using scene editor position.")
		return false

	# Stats
	if data.has("stats"):
		player.stats.scrap = data.stats.scrap
		player.stats.stamina = data.stats.stamina

	print("Loaded (inventory kept empty).")
	return true
