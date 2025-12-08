extends Node2D

# -------------------------
# Signals
# -------------------------
signal demand_updated(new_demand: Array)
signal demand_met()
signal demand_failed(deficit: Array)

# -------------------------
# Exported Variables
# -------------------------
@export var items_folder_path: String = "res://assets/items/"
@export var rarity_filter: String = ""           # "common", "rare", "legendary", or empty
@export var demand_count: int = 3                # How many items to request per demand
@export var items_needed_count: int = 1          # How many items this terminal picks from demand

@export var player_node: Node = null             # Optional: assign in editor
@export var world_state_path: NodePath           # Optional: assign in editor

# -------------------------
# Node References
# -------------------------
@onready var panel: Panel = $Panel
@onready var item_container: HBoxContainer = $Panel/VBoxContainer/ItemContainer
@onready var press_e_label: Label = $Panel/VBoxContainer/PressELabel

# -------------------------
# Internal Variables
# -------------------------
var current_demand_items: Array = []
var required_items: Array = []

var player_ref: Node = null
var can_interact: bool = false
var is_completed: bool = false

var world_state: Node = null

# -------------------------
# Ready
# -------------------------
func _ready():
	# Assign world state
	if world_state_path != NodePath(""):
		world_state = get_node_or_null(world_state_path)

	# Initialize first demand
	_generate_new_demand()
	_update_item_display()

	# Set label text
	if press_e_label:
		press_e_label.text = "Press E to deposit items"

	# Hide panel initially
	panel.visible = false

	# Connect Area2D signals
	if has_node("Area2D"):
		$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))
		$Area2D.connect("body_exited", Callable(self, "_on_body_exited"))

# -------------------------
# Player Interaction
# -------------------------
func _process(_delta):
	if can_interact and Input.is_action_just_pressed("interact"):
		_try_deposit_items()

func _on_body_entered(body):
	if body.is_in_group("Player") and not is_completed:
		can_interact = true
		player_ref = body
		panel.visible = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		can_interact = false
		player_ref = null
		panel.visible = false
		if press_e_label:
			press_e_label.text = "Press E to deposit items"

# -------------------------
# Demand Generation
# -------------------------
func _generate_new_demand():
	current_demand_items = _get_random_items_from_folder(demand_count, rarity_filter)
	if current_demand_items.is_empty():
		push_error("No items found to generate demand!")
		return

	# Pick a subset for this terminal
	required_items = current_demand_items.slice(0, items_needed_count)
	_update_item_display()
	emit_signal("demand_updated", required_items)

# -------------------------
# Load Random Items
# -------------------------
func _get_random_items_from_folder(count: int, filter: String = "") -> Array:
	var available_items: Array = []
	var rarities = ["common", "uncommon", "rare", "legendary"]

	if filter != "":
		_collect_items_in_folder(items_folder_path + filter + "/", available_items)
	else:
		for r in rarities:
			_collect_items_in_folder(items_folder_path + r + "/", available_items)

	if current_demand_items.is_empty():
		_collect_items_in_folder(items_folder_path, available_items)

	available_items.shuffle()
	return available_items.slice(0, min(count, available_items.size()))

func _collect_items_in_folder(path: String, out: Array):
	var dir = DirAccess.open(path)
	if not dir:
		return
	dir.list_dir_begin()
	var f = dir.get_next()
	while f != "":
		if not dir.current_is_dir() and f.ends_with(".png"):
			out.append({
				"name": f.get_basename(),
				"icon_path": path + f
			})
		f = dir.get_next()
	dir.list_dir_end()

# -------------------------
# Update Panel Display
# -------------------------
func _update_item_display():
	if not item_container:
		push_error("Item container missing!")
		return

	# Clear existing icons
	for child in item_container.get_children():
		child.queue_free()

	# Add new icons
	for item_data in required_items:
		var icon_path = item_data.get("icon_path", "")
		if icon_path != "" and FileAccess.file_exists(icon_path):
			var tex = load(icon_path)
			if tex:
				var tex_rect = TextureRect.new()
				tex_rect.texture = tex
				tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				tex_rect.custom_minimum_size = Vector2(32,32)
				item_container.add_child(tex_rect)

# -------------------------
# Try Depositing Items
# -------------------------
func _try_deposit_items():
	if not player_ref:
		return

	var item_names = required_items.map(func(i): return i["name"])

	if player_ref.has_method("has_items") and player_ref.has_method("remove_items"):
		if player_ref.has_items(item_names):
			# Player has all items
			player_ref.remove_items(item_names)
			print("Deposited all items to", name)
			_complete_terminal()
			emit_signal("demand_met")
		else:
			print("Missing items!")
			_show_missing_items_feedback()
			emit_signal("demand_failed", item_names)
	else:
		push_error("Player missing required methods!")

# -------------------------
# Feedback
# -------------------------
func _show_missing_items_feedback():
	if panel:
		var orig = panel.modulate
		var tween = create_tween()
		tween.tween_property(panel, "modulate", Color.RED, 0.1)
		tween.tween_property(panel, "modulate", orig, 0.2)

	if press_e_label:
		press_e_label.text = "Missing items!"
		await get_tree().create_timer(2.0).timeout
		if can_interact:
			press_e_label.text = "Press E to deposit"

# -------------------------
# Complete Terminal
# -------------------------
func _complete_terminal():
	is_completed = true
	can_interact = false
	panel.visible = false

	if has_node("Sprite2D"):
		var sprite = get_node("Sprite2D")
		sprite.modulate = Color(0.5, 1.0, 0.5)

	# Optionally update world state
	if world_state and world_state.has_method("Update_Stability"):
		world_state.Update_Stability(2.0)
