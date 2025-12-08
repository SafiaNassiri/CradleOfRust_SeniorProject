extends Node

signal inventory_updated

const GRID_ROWS := 4
const GRID_COLUMNS := 6
const MAX_SLOTS := GRID_ROWS * GRID_COLUMNS

var count = 0

# Array of dictionaries: {id = String, amount = int}
var inventory_slots: Array = []

# --------------------- ADD -----------------------
func Add_Item(id: String, amount: int = 1):
	count += 1
	print (count)
	if not ItemDatabase.ITEMS.has(id):
		push_error("Unknown item: " + id)
		return

	for slot in inventory_slots:
		if slot.id == id:
			slot.amount += amount
			_sort_inventory()
			emit_signal("inventory_updated")
			return

	if inventory_slots.size() < MAX_SLOTS:
		inventory_slots.append({"id": id, "amount": amount})
		_sort_inventory()
		emit_signal("inventory_updated")
	else:
		print("Inventory FULL!")

# --------------------- REMOVE -----------------------
func Remove_Item(id: String, amount: int = 1):
	count -= 1
	print(count)
	for slot in inventory_slots:
		if slot.id == id:
			slot.amount -= amount
			if slot.amount <= 0:
				inventory_slots.erase(slot)
			_sort_inventory()
			emit_signal("inventory_updated")
			return

# --------------------- COUNT -----------------------
func Count(id: String) -> int:
	for slot in inventory_slots:
		if slot.id == id:
			return slot.amount
	return 0

# --------------------- RETURN ALL ------------------
func Get_All() -> Array:
	return inventory_slots.duplicate(true)

# --------------------- SORTING ---------------------
func _sort_inventory():
	inventory_slots.sort_custom(Callable(self, "_sort_compare"))

func _sort_compare(a, b):
	var info_a = ItemDatabase.ITEMS[a.id]
	var info_b = ItemDatabase.ITEMS[b.id]

	if info_a.rarity != info_b.rarity:
		return info_a.rarity < info_b.rarity  # rarer first

	return a.id < b.id  # A–Z

func _ready():
	add_to_group("Inventory")
