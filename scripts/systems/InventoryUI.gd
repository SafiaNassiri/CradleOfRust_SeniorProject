extends Control

@export var item_icon_size: Vector2 = Vector2(48, 48)  # icon size
@onready var item_list: VBoxContainer = $Panel/VBoxContainer
var is_visible := false

func _ready():
	visible = false

func toggle():
	is_visible = !is_visible
	visible = is_visible
	if is_visible:
		update_inventory()

# Update the inventory display
func update_inventory():
	item_list.clear()  # remove previous items

	for item_data in Inventory.Get_All():  # use your Inventory system
		var hbox = HBoxContainer.new()

		# Load icon
		var tex = ItemDatabase.ITEMS[item_data.id].icon
		var icon = TextureRect.new()
		icon.texture = tex
		icon.rect_min_size = item_icon_size
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(icon)

		# Item label
		var label = Label.new()
		label.text = "%s x%s" % [item_data.id, item_data.amount]
		hbox.add_child(label)

		item_list.add_child(hbox)
