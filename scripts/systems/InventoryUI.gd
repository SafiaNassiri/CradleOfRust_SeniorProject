extends Control

@export var item_icon_size: Vector2 = Vector2(32, 32)
@export var max_rows: int = 12  # max items per column

@onready var item_grid: GridContainer = $Panel/GridContainer

func _ready():
	visible = false
	Inventory.connect("inventory_updated", Callable(self, "_on_inventory_updated"))

func toggle():
	visible = not visible
	if visible:
		update_inventory()

func _on_inventory_updated():
	if visible:
		update_inventory()

func update_inventory():
	# Clear old items
	for child in item_grid.get_children():
		child.queue_free()

	# Add updated items
	for item_data in Inventory.Get_All():
		var vbox = VBoxContainer.new()

		# Icon
		var icon = TextureRect.new()
		icon.texture = ItemDatabase.ITEMS[item_data.id].icon
		icon.custom_minimum_size = item_icon_size
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		vbox.add_child(icon)

		# Label
		var label = Label.new()
		label.text = "%s x%s" % [item_data.id, item_data.amount]
		vbox.add_child(label)

		item_grid.add_child(vbox)
