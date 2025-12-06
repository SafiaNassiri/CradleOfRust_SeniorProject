extends Node

var facility_upgrades := {}
var player_upgrades := {}

func _ready():
	load_data()

func load_data():
	var file = FileAccess.open("res://data/system_data.json", FileAccess.READ)
	if not file:
		push_error("SystemData: Cannot open system_data.json")
		return
	
	var text = file.get_as_text()
	var result = JSON.parse_string(text)

	if result is Dictionary:

		# Load old data
		facility_upgrades = result.get("facility_upgrades", {})
		player_upgrades   = result.get("player_upgrades", {})

		# NEW: Load resources into ResourceManager
		if result.has("resources"):
			ResourceManager.load_from_save(result["resources"])
		else:
			print("SystemData: No resource data found in save")

	else:
		push_error("SystemData: Invalid JSON format")
