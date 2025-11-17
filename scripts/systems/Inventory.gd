extends Node

signal inventory_updated

const GRID_ROWS := 4
const GRID_COLUMNS := 6
const MAX_SLOTS := GRID_ROWS * GRID_COLUMNS

# Array of items: {id, amount}
var inventory_slots: Array = []

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

	# Add new slot if space
	if inventory_slots.size() < MAX_SLOTS:
		var slot := {"id": id, "amount": amount}
		inventory_slots.append(slot)
		_sort_inventory()
		emit_signal("inventory_updated")
	else:
		print("Inventory FULL!")

func Remove_Item(id: String, amount: int = 1):
	for slot in inventory_slots:
		if slot.id == id:
			slot.amount -= amount
			if slot.amount <= 0:
				inventory_slots.erase(slot)
			_sort_inventory()
			emit_signal("inventory_updated")
			return

func Count(id: String) -> int:
	for slot in inventory_slots:
		if slot.id == id:
			return slot.amount
	return 0

func Get_All() -> Array:
	return inventory_slots.duplicate(true)

# Sort by rarity (lower number = rarer) then alphabetically
func _sort_inventory():
	inventory_slots.sort_custom(Callable(self, "_sort_compare"))

func _sort_compare(a, b):
	var info_a = ItemDatabase.ITEMS[a.id]
	var info_b = ItemDatabase.ITEMS[b.id]

	# Lower rarity number = rarer first
	if info_a.rarity != info_b.rarity:
		return info_a.rarity < info_b.rarity

	# Same rarity → alphabetical
	return a.id < b.id
