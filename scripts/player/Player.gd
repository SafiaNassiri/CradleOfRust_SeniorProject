extends CharacterBody2D

# --- Nodes ---
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stats = preload("res://scripts/player/PlayerStats.gd").new()
@onready var storage = preload("res://scripts/player/PlayerStorage.gd").new()
@onready var interact_hint: Label = $InteractHint
@onready var inventory_ui = get_parent().get_node("CanvasLayer/InventoryUi")

# --- Player Stats ---
var gender: String = "male"
var direction: String = "down"
var state: String = "idle"
var speed := 150.0
var sprint_multiplier := 1.8
var is_sprinting := false

# --- Interaction ---
var nearby_interactables := []  # List of Area2D nodes in range
var current_interactable: Node = null

# --- Inventory ---
var inventory := []

# -------------------- PROCESS --------------------
func _process(delta):
	# Toggle inventory UI
	if Input.is_action_just_pressed("toggle_inventory"):
		inventory_ui.visible = not inventory_ui.visible
		if inventory_ui.visible:
			print_inventory()  # Debug print

# -------------------- READY --------------------
func _ready():
	_load_player_prefs()
	_setup_animations()
	storage.load(self)
	if interact_hint:
		interact_hint.visible = false
	if inventory_ui:
		inventory_ui.visible = false

# -------------------- PHYSICS --------------------
func _physics_process(delta):
	_handle_movement(delta)
	_check_interaction_input()

func _handle_movement(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	is_sprinting = Input.is_action_pressed("Dash") and stats.stamina > 0
	var current_speed = speed * (sprint_multiplier if is_sprinting else 1.0)
	velocity = input_vector * current_speed
	move_and_slide()

	if is_sprinting:
		stats.use_stamina(delta * 10)
	else:
		stats.recover_stamina(delta * 5)

	_update_animation(input_vector)

# -------------------- ANIMATION --------------------
func _update_animation(input_vector: Vector2):
	if input_vector == Vector2.ZERO:
		state = "idle"
	else:
		state = "walk"
		if input_vector.x > 0 and input_vector.y > 0:
			direction = "rightdown"
		elif input_vector.x < 0 and input_vector.y > 0:
			direction = "leftdown"
		elif input_vector.x > 0 and input_vector.y < 0:
			direction = "rightup"
		elif input_vector.x < 0 and input_vector.y < 0:
			direction = "leftup"
		elif input_vector.x > 0:
			direction = "rightdown"
		elif input_vector.x < 0:
			direction = "leftdown"
		elif input_vector.y > 0:
			direction = "down"
		elif input_vector.y < 0:
			direction = "up"

	var anim_name = "%s_%s" % [state, direction]
	if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation(anim_name):
		if anim_sprite.animation != anim_name:
			anim_sprite.play(anim_name)

# -------------------- PLAYER PREFS --------------------
func _load_player_prefs():
	if FileAccess.file_exists("user://prefs.json"):
		var file = FileAccess.open("user://prefs.json", FileAccess.READ)
		var parse_result = JSON.parse_string(file.get_as_text())
		file.close()
		if parse_result.error == OK and parse_result.result.has("gender"):
			gender = parse_result.result["gender"]

func _setup_animations():
	var frames_path = "res://assets/player/%s/%s.tres" % [gender, gender]
	if ResourceLoader.exists(frames_path, "SpriteFrames"):
		anim_sprite.sprite_frames = load(frames_path)
	else:
		push_warning("⚠️ Missing SpriteFrames for '%s', loading male as fallback" % gender)
		anim_sprite.sprite_frames = load("res://assets/player/male/male.tres")

# -------------------- INTERACTION --------------------
func _check_interaction_input():
	if current_interactable and Input.is_action_just_pressed("interact"):
		if current_interactable.has_method("_give_random_item"):
			current_interactable._give_random_item()
		elif current_interactable.has_method("_deposit_and_spawn"):
			current_interactable._deposit_and_spawn()

func register_interactable(interactable_node: Node):
	if interactable_node not in nearby_interactables:
		nearby_interactables.append(interactable_node)
	print("Registered interactable:", interactable_node.name)
	_update_current_interactable()

func unregister_interactable(interactable_node: Node):
	if interactable_node in nearby_interactables:
		nearby_interactables.erase(interactable_node)
	_update_current_interactable()

func _update_current_interactable():
	if nearby_interactables.size() > 0:
		current_interactable = nearby_interactables[0]
		if interact_hint:
			interact_hint.visible = true
	else:
		current_interactable = null
		if interact_hint:
			interact_hint.visible = false

# -------------------- STORAGE --------------------
func _exit_tree():
	storage.save(self)

# -------------------- INVENTORY --------------------
func has_items(required_items: Array) -> bool:
	for item in required_items:
		if item not in inventory:
			return false
	return true

func remove_items(items_to_remove: Array) -> void:
	for item in items_to_remove:
		inventory.erase(item)

func add_item(item_name: String):
	inventory.append(item_name)
	print("Added to inventory:", item_name)

func print_inventory():
	print("--- Inventory ---")
	for i in inventory:
		print(i)
	print("---------------")
