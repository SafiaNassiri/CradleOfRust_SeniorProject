extends Control

@export var item_icon_size: Vector2 = Vector2(32, 32)
@export var max_visible_rows: int = 8  # max rows before vertical scroll activates
@export var padding: int = 4           # spacing between items

@onready var panel: PanelContainer = $PanelContainer
@onready var scroll: ScrollContainer = $PanelContainer/VBoxContainer/ScrollContainer
@onready var grid: VBoxContainer = $PanelContainer/VBoxContainer/ScrollContainer/ItemsVBox
@onready var header_label: Label = $PanelContainer/VBoxContainer/Label

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.inventory.connect("inventory_updated", Callable(self, "_on_inventory_updated"))

func toggle():
	visible = not visible
	if visible:
		update_inventory()

func _on_inventory_updated():
	if visible:
		update_inventory()

func update_inventory():
	if not grid:
		push_error("Items VBoxContainer not found!")
		return

	# Clear previous items
	for child in grid.get_children():
		child.queue_free()

	var items = Inventory.Get_All()
	if items.size() == 0:
		return

	# Add items vertically
	for item_data in items:
		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_FILL
		hbox.size_flags_vertical = Control.SIZE_FILL
		hbox.custom_minimum_size.y = item_icon_size.y + padding

		# Icon
		var icon = TextureRect.new()
		icon.texture = ItemDatabase.ITEMS[item_data.id].icon
		icon.custom_minimum_size = item_icon_size
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(icon)

		# Label
		var label = Label.new()
		label.text = "%s x%s" % [item_data.id, item_data.amount]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.clip_text = false   # make sure full text shows
		hbox.add_child(label)

		grid.add_child(hbox)

	# ---------------------------
	# Auto-size ScrollContainer height
	# ---------------------------

	var row_height = item_icon_size.y + padding
	var buffer = 8 # extra space between last text and scrollbar
	var visible_rows = min(items.size(), max_visible_rows)
	var target_height = visible_rows * row_height + buffer

	# Optional: minimum panel height before scrollbar appears
	var min_panel_height = 100
	scroll.custom_minimum_size.y = max(target_height, min_panel_height)
