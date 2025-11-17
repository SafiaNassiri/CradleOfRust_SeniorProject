extends Node

signal inventory_updated

# -----------------------------------------------------
# GRID INVENTORY SETTINGS
# -----------------------------------------------------
const GRID_ROWS := 4
const GRID_COLUMNS := 6
const MAX_SLOTS := GRID_ROWS * GRID_COLUMNS

# inventory_slots is an ARRAY of inventory entries:
# [ {"id": "scrap", "amount": 3}, {"id": "gem", "amount": 1}, ... ]
var inventory_slots: Array = []

# -----------------------------------------------------
# Add an item by ID
# Auto-sorts by rarity
# -----------------------------------------------------
func Add_Item(id: String, amount: int = 1):
	if not ItemDatabase.ITEMS.has(id):
		push_error("Item does not exist: " + id)
		return

	# Try to stack with existing
	for slot in inventory_slots:
		if slot.id == id:
			slot.amount += amount
			_sort_inventory()
			emit_signal("inventory_updated")
			return

	# If not found, add new slot if space is left
	if inventory_slots.size() < MAX_SLOTS:
		var slot := {
			"id": id,
			"amount": amount
		}
		inventory_slots.append(slot)
		_sort_inventory()
		emit_signal("inventory_updated")
	else:
		print("Inventory FULL!")

# -----------------------------------------------------
# Remove item
# -----------------------------------------------------
func Remove_Item(id: String, amount: int = 1):
	for slot in inventory_slots:
		if slot.id == id:
			slot.amount -= amount
			if slot.amount <= 0:
				inventory_slots.erase(slot)
			_sort_inventory()
			emit_signal("inventory_updated")
			return

# -----------------------------------------------------
# Count how many player owns
# -----------------------------------------------------
func Count(id: String) -> int:
	for slot in inventory_slots:
		if slot.id == id:
			return slot.amount
	return 0

# -----------------------------------------------------
# Get entire grid inventory (for UI)
# -----------------------------------------------------
func Get_All() -> Array:
	return inventory_slots.duplicate(true)

# -----------------------------------------------------
# Auto sort inventory by rarity → name
# -----------------------------------------------------
func _sort_inventory():
	# Pass a callable to the comparison function
	inventory_slots.sort_custom(Callable(self, "_sort_compare"))

func _sort_compare(a, b):
	var info_a = ItemDatabase.ITEMS[a.id]
	var info_b = ItemDatabase.ITEMS[b.id]

	# Lower rarity number = rarer first
	if info_a.rarity != info_b.rarity:
		return info_a.rarity < info_b.rarity

	# If same rarity, sort alphabetically
	return a.id < b.id
