extends Node
class_name PlayerStorage

const SAVE_PATH := "user://player_save.json"

func save(player):
	var data: Dictionary = {
		"inventory": Inventory.inventory_slots,
		"stats": {
			"scrap": player.stats.scrap,
			"stamina": player.stats.stamina
		},
		"position": [player.global_position.x, player.global_position.y]
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("💾 Saved.")
		

func load(player):
	if not FileAccess.file_exists(SAVE_PATH):
		print("⚠️ No save file.")
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if typeof(data) != TYPE_DICTIONARY:
		print("⚠️ Save invalid.")
		return

	# --- ALWAYS start with empty inventory ---
	Inventory.inventory_slots.clear()

	# Position
	if data.has("position"):
		var p = data.position
		player.global_position = Vector2(p[0], p[1])

	# Stats
	if data.has("stats"):
		player.stats.scrap = data.stats.scrap
		player.stats.stamina = data.stats.stamina

	print("✅ Loaded (inventory cleared).")
