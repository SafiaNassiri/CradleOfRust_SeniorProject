extends Node

# Track multiple resource types
var resources := {
	"scrap": 0,
	"biofuel": 0,
	"water": 0
}

# ---------------------------
# Load / Save
# ---------------------------
func load_resources():
	if FileAccess.file_exists("user://resources.json"):
		var file = FileAccess.open("user://resources.json", FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		
		if data is Dictionary:
			for key in resources.keys():
				resources[key] = data.get(key, resources[key])
			print("Loaded resources:", resources)
		else:
			push_error("ResourceManager: Invalid JSON format!")

func save_resources():
	var file = FileAccess.open("user://resources.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(resources))
	file.close()
	print("Saved resources:", resources)

# ---------------------------
# Resource Functions
# ---------------------------

func Add_Resource(type: String, amount: int) -> void:
	if not resources.has(type):
		push_error("Unknown resource type: %s" % type)
		return
	resources[type] += amount
	save_resources()
	print("Added", amount, type, "-> Now:", resources[type])

func Spend_Resource(type: String, amount: int) -> bool:
	# Returns true if success, false if not enough
	if not resources.has(type):
		push_error("Unknown resource type: %s" % type)
		return false
	
	if resources[type] < amount:
		print("Not enough", type, "(have:", resources[type], "need:", amount, ")")
		return false
	
	resources[type] -= amount
	save_resources()
	print("✔ Spent", amount, type, "-> Remaining:", resources[type])
	return true
