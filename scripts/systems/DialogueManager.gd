extends Node

var events := {}
var decision_points := {}

func _ready():
	load_dialogue_file()

func load_dialogue_file():
	var file_path = "res://data/dialogue_events.json"
	if not FileAccess.file_exists(file_path):
		push_error("Dialogue file missing: " + file_path)
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Dialogue JSON invalid!")
		return
	
	events = data.get("events", {})
	decision_points = data.get("decision_points", {})
	
	print("DialogueManager: Loaded", events.size(), "events and", decision_points.size(), "decision points.")

func get_event(id: String) -> Dictionary:
	return events.get(id, {})

func get_decision(id: String) -> Dictionary:
	return decision_points.get(id, {})

func get_lines(id: String) -> Array:
	var ev = get_event(id)
	return ev.get("lines", [])

func get_trigger(id: String) -> Dictionary:
	var ev = get_event(id)
	return ev.get("trigger", {})
