extends Node

signal demand_increased(new_demand: Array)   # List of required items
signal demand_not_met(deficit: Array)
signal demand_met()

@export var items_folder_path: String = "res://assets/items/"
@export var rarity_filter: String = ""  
@export var demand_count: int = 3  

# set this in editor to point to the player node
@export var player_node: Node = null

# world state reference for stability updates
@export var world_state_path: NodePath
var world_state: Node = null

var current_demand_items := []

func _ready():
	if world_state_path != NodePath(""):
		world_state = get_node_or_null(world_state_path)

	_generate_new_demand()
	print("FacilityDemands initialized.")


func _find_world_state():
	if world_state_path != NodePath("") and has_node(world_state_path):
		world_state = get_node(world_state_path)
		return
	
	if Engine.has_singleton("WorldState"):
		world_state = Engine.get_singleton("WorldState")
		return
	
	var root = get_tree().root
	world_state = _find_node_recursive(root, "WorldState")

func _find_node_recursive(node: Node, search_name: String) -> Node:
	if search_name.to_lower() in node.name.to_lower() and node.has_method("Update_Stability"):
		return node
	for child in node.get_children():
		var result = _find_node_recursive(child, search_name)
		if result:
			return result
	return null

# -------------------------
# Generate demand items
# -------------------------
func _generate_new_demand(rarity_filter_override: String = ""):
	var filter_to_use = rarity_filter_override if rarity_filter_override != "" else rarity_filter
	current_demand_items = _get_random_items_from_folder(demand_count, filter_to_use)

	if current_demand_items.is_empty():
		push_error("⚠ WARNING: Generated EMPTY demands!")
	else:
		print("Facility demand generated:", current_demand_items)
		emit_signal("demand_increased", current_demand_items)

func _get_random_items_from_folder(count: int, filter: String = "") -> Array:
	var available_items := []

	var rarities = ["common", "uncommon", "rare", "legendary"]

	if filter != "":
		var specific_path = items_folder_path + filter + "/"
		_collect_items_in_folder(specific_path, available_items)
	else:
		# Search all rarity subfolders
		for r in rarities:
			var p = items_folder_path + r + "/"
			_collect_items_in_folder(p, available_items)

	if available_items.is_empty():
		_collect_items_in_folder(items_folder_path, available_items)

	if available_items.is_empty():
		push_error("⚠ WARNING: No items found in ANY folder: " + items_folder_path)
		return []

	available_items.shuffle()
	return available_items.slice(0, min(count, available_items.size()))

func _collect_items_in_folder(path: String, out: Array):
	var dir = DirAccess.open(path)
	if not dir:
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".png"):
			out.append({
				"name": file_name.get_basename(),
				"icon_path": path + file_name
			})
		file_name = dir.get_next()
	dir.list_dir_end()

# -------------------------
# Process Demand
# -------------------------

func _get_player() -> Node:
	if player_node and player_node.has_method("has_items"):
		return player_node
	# Fallback: search by group
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("has_items"):
		return player
	push_error("FacilityDemands: No player found with has_items()!")
	return null

func _meet_demand():
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var items_to_remove = []
		for item in current_demand_items:
			items_to_remove.append(item["name"])  # use ["name"] to access dictionary
		player.remove_items(items_to_remove)
	
	print("Facility demand met!")
	emit_signal("demand_met")
	
	if world_state:
		world_state.Update_Stability(2.0)

func _fail_demand(deficit: Array):
	print("Facility demand not met!")
	if world_state:
		world_state.Update_Stability(-len(deficit) * 5)  # Penalty per missing item
	emit_signal("demand_not_met", deficit)
