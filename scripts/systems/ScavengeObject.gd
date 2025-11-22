extends Node2D

signal respawn_needed(rarity)

@onready var area = $Area2D
@onready var prompt = $Prompt
@onready var promptBG = $Panel
@onready var respawn_timer = $RespawnTimer
@onready var sprite = $Sprite2D

var player_in_range := false
var collected := false

var rarity_weights = {"common": 70, "uncommon": 20, "rare": 9, "legendary": 1}
var item_textures := {"common": [], "uncommon": [], "rare": [], "legendary": []}
var chosen_item_id := ""

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	prompt.visible = false
	promptBG.visible = false
	load_item_sprites()
	set_random_sprite()

func load_item_sprites():
	var base_path = "res://assets/items/"
	for rarity in item_textures.keys():
		var full_path = base_path + rarity + "/"
		var dir := DirAccess.open(full_path)
		if not dir:
			continue
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.ends_with(".png") or file.ends_with(".webp") or file.ends_with(".jpg"):
				item_textures[rarity].append(load(full_path + file))
			file = dir.get_next()
		dir.list_dir_end()

func pick_rarity_weighted() -> String:
	var total_weight = 0
	for weight in rarity_weights.values():
		total_weight += weight
	var r = randf() * total_weight
	var running = 0
	for rarity in rarity_weights.keys():
		running += rarity_weights[rarity]
		if r <= running:
			return rarity
	return "common"

func set_random_sprite():
	var rarity = pick_rarity_weighted()
	var arr = item_textures[rarity]
	if arr.size() > 0:
		var tex: Texture2D = arr.pick_random()
		sprite.texture = tex
		chosen_item_id = tex.resource_path.get_file().get_basename()
	else:
		sprite.texture = null
		chosen_item_id = ""

func _on_body_entered(body):
	print("Body entered:", body.name, "Group Player:", body.is_in_group("Player"))
	if body.is_in_group("Player") and not collected:
		player_in_range = true
		prompt.visible = true
		promptBG.visible = true
		if body.has_method("register_interactable"):
			body.register_interactable(self)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		prompt.visible = false
		promptBG.visible = false
		if body.has_method("unregister_interactable"):
			body.unregister_interactable(self)  # <-- unregister

func _process(_delta):
	if player_in_range and not collected and Input.is_action_just_pressed("interact"):
		_give_random_item()

func _give_random_item():
	if collected:
		return

	collected = true
	prompt.visible = false
	promptBG.visible = false

	if chosen_item_id != "":
		Inventory.Add_Item(chosen_item_id, 1)  # adds to Inventory singleton
		Inventory.emit_signal("inventory_updated") # <- ADD THIS
		print("Updating UI...")
		print("Current inventory:", Inventory.Get_All())
		print("Picked up:", chosen_item_id)

	sprite.visible = false
	area.monitoring = false
	area.set_deferred("monitorable", false)

	var item_rarity = get_item_rarity(chosen_item_id)
	emit_signal("respawn_needed", item_rarity)

func get_item_rarity(id: String) -> String:
	for rarity in item_textures.keys():
		for tex in item_textures[rarity]:
			if tex.resource_path.get_file().get_basename() == id:
				return rarity
	return "common"

func _on_RespawnTimer_timeout():
	respawn()

func respawn():
	collected = false
	set_random_sprite()
	sprite.visible = true
	area.monitoring = true
	area.monitorable = true
	if player_in_range:
		prompt.visible = true
		promptBG.visible = true
