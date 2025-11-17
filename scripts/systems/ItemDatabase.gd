extends Node

# All items loaded from folders: {id: {rarity:int, icon:Texture2D}}
var ITEMS := {}

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
	var filename = dir.get_next()

	while filename != "":
		if not dir.current_is_dir() and filename.ends_with(".png"):
			var id := filename.get_basename()
			var tex := load(path + filename)
			ITEMS[id] = {"rarity": rarity, "icon": tex}
		filename = dir.get_next()
	dir.list_dir_end()
	
