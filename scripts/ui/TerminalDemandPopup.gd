extends Control

# -------------------------
# Terminal Demand Popup
# Shows required items when hovering over terminal
# -------------------------

@onready var panel: Panel = $Panel
@onready var terminal_name_label: Label = $Panel/VBoxContainer/TerminalNameLabel
@onready var item_container: HBoxContainer = $Panel/VBoxContainer/ItemContainer
@onready var press_e_label: Label = $Panel/VBoxContainer/PressELabel

# Positioning
@export var offset_above_terminal := Vector2(0, -80)  # Pixels above terminal

var current_terminal: Node = null
var is_visible := false

# -------------------------
# Ready
# -------------------------
func _ready():
	visible = false
	
	if press_e_label:
		press_e_label.text = "Press E to interact"

# -------------------------
# Process
# -------------------------
func _process(_delta: float):
	if current_terminal and is_visible:
		_update_position()

# -------------------------
# Show popup for a terminal
# -------------------------
func show_for_terminal(terminal: Node):
	if not terminal:
		hide_popup()
		return
	
	current_terminal = terminal
	is_visible = true
	
	# Show terminal name
	if terminal_name_label:
		terminal_name_label.text = terminal.name
	
	# Get required items from terminal
	var required_items = []
	if terminal.has("required_items"):
		required_items = terminal.required_items
	
	# Update display
	_update_item_display(required_items)
	_update_position()
	
	visible = true

# -------------------------
# Hide popup
# -------------------------
func hide_popup():
	current_terminal = null
	is_visible = false
	visible = false

# -------------------------
# Update item icons
# -------------------------
func _update_item_display(required_items: Array):
	# Clear existing icons
	for child in item_container.get_children():
		child.queue_free()
	
	# Add new icons
	for item_name in required_items:
		var icon_texture = ItemDatabase.get_icon(item_name)
		if icon_texture:
			var tex_rect = TextureRect.new()
			tex_rect.texture = icon_texture
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_rect.custom_minimum_size = Vector2(24, 24)
			item_container.add_child(tex_rect)

# -------------------------
# Update position above terminal
# -------------------------
func _update_position():
	if not current_terminal:
		return
	
	# Get terminal's screen position
	var terminal_global_pos = current_terminal.global_position
	
	# Convert world position to screen position
	var canvas_transform = get_canvas_transform()
	var screen_pos = canvas_transform * terminal_global_pos
	
	# Position above terminal, centered
	var ui_size = size
	var popup_pos = screen_pos - Vector2(ui_size.x / 2.0, ui_size.y) + offset_above_terminal
	
	global_position = popup_pos
