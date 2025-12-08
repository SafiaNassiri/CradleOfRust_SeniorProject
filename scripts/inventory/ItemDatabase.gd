extends Node

# All items: { "id": {"rarity": int, "icon": Texture2D} }
var ITEMS: Dictionary = {}

func _ready():
	_load_items_from_folder("res://assets/items/common/", 3)
	_load_items_from_folder("res://assets/items/uncommon/", 2)
	_load_items_from_folder("res://assets/items/rare/", 1)
	_load_items_from_folder("res://assets/items/legendary/", 0)
	print("ItemDatabase loaded:", ITEMS.keys())

func _load_items_from_folder(path: String, rarity: int):
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Folder does not exist: " + path)
		return

	dir.list_dir_begin()
	var file = dir.get_next()

	while file != "":
		if not dir.current_is_dir() and file.ends_with(".png"):
			var id := file.get_basename()
			var tex := load(path + file)
			ITEMS[id] = {
				"rarity": rarity,
				"icon": tex
			}
		file = dir.get_next()

	dir.list_dir_end()


func get_random_items(count: int) -> Array:
	var keys := ITEMS.keys()
	var result := []
	while result.size() < count and keys.size() > 0:
		var idx = randi() % keys.size()
		result.append(keys[idx])
		keys.remove_at(idx)
	return result

func get_icon(item_id: String) -> Texture2D:
	if ITEMS.has(item_id):
		return ITEMS[item_id]["icon"]
	return null
