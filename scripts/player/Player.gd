extends CharacterBody2D

const SaveTools = preload("res://scripts/systems/SaveTools.gd")

# --- Nodes ---
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var stats = preload("res://scripts/player/PlayerStats.gd").new()
@onready var storage = preload("res://scripts/player/PlayerStorage.gd").new()
@onready var interact_hint: Label = $InteractHint
@export var walk_sound: AudioStream
@export var action_sound: AudioStream
@export var item_pickup_sound: AudioStream

# --- Player Stats ---
var gender: String = "male"
var direction: String = "down"
var state: String = "idle"
var speed := 150.0
var sprint_multiplier := 1.8
var is_sprinting := false

# --- Interaction ---
var nearby_interactables := []
var current_interactable: Node = null

# --- Inventory ---
var inventory_ui: Node = null
var inventory := []

# --- Sounds ---
var is_walking_sound_playing := false

# -------------------- PROCESS --------------------
func _process(_delta):
	# Toggle Inventory
	if Input.is_action_just_pressed("toggle_inventory") and inventory_ui:
		inventory_ui.toggle()
		if inventory_ui.visible:
			print_inventory()

	# Wipe save: show confirmation popup
	if Input.is_action_just_pressed("clear_save"):
		_show_wipe_confirm()

func _show_wipe_confirm():
	var popup = get_tree().current_scene.get_node("===UI===/HUD/WipeConfirmPopup")
	if popup:
		popup.popup_centered()

func _on_wipe_confirmed():
	SaveTools.wipe_all_saves()

func _ready():
	# Disable player movement
	set_physics_process(false)
	set_process_input(false)

	# Wait for scene to be ready
	await get_tree().process_frame

	# Load and play intro cutscene using CutsceneLayer
	var cutscene_layer = get_node("../===UI===/CutsceneLayer")
	if cutscene_layer:
		var sequence = cutscene_layer.load_cutscene("res://data/cutscenes/intro.json")
		cutscene_layer.play_cutscene(sequence)
		await cutscene_layer.finished_cutscene
	
	# Re-enable player movement
	set_physics_process(true)
	set_process_input(true)
	
	# Continue with normal setup
	_connect_ui()
	_load_player_prefs()
	_setup_animations()
	storage.load(self)

	if interact_hint:
		interact_hint.visible = false

# Delayed UI connection to avoid get_node() errors
func _connect_ui():
	var current_scene = get_tree().current_scene
	if not current_scene:
		push_error("Current scene is null! Player loaded too early.")
		return

	# Use full path from MainLevel
	var hud = current_scene.get_node_or_null("===UI===/HUD")
	if not hud:
		push_error("HUD not found at ===UI===/HUD!")
		return

	inventory_ui = hud.get_node_or_null("InventoryUI")
	if not inventory_ui:
		push_error("InventoryUI missing under HUD!")
	else:
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
		stats.Use_Stamina(delta * 10)
	else:
		stats.Recover_Stamina(delta * 5)
	
	# Determine if moving
	var moving = input_vector != Vector2.ZERO

	# Play/stop walking sound
	if moving:
		if not is_walking_sound_playing:
			AudioManager.play_sfx(walk_sound)
			is_walking_sound_playing = true
	else:
		if is_walking_sound_playing:
			AudioManager.sfx_player.stop()
			is_walking_sound_playing = false

	# Update animation with the correct state
	_update_animation(input_vector)

# -------------------- ANIMATION --------------------
func _update_animation(input_vector: Vector2):
	if input_vector == Vector2.ZERO:
		state = "idle"
	else:
		state = "walk"

		# 8-direction + forced straight left/right mapping
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
		var parsed = JSON.parse_string(file.get_as_text())
		file.close()

		if parsed and parsed.has("gender"):
			gender = parsed["gender"]

func _setup_animations():
	var frames_path = "res://assets/player/%s/%s.tres" % [gender, gender]

	if ResourceLoader.exists(frames_path, "SpriteFrames"):
		anim_sprite.sprite_frames = load(frames_path)
	else:
		push_warning("⚠ Missing sprite frames for '%s', defaulting to male." % gender)
		anim_sprite.sprite_frames = load("res://assets/player/male/male.tres")

# -------------------- INTERACTION --------------------
func _check_interaction_input():
	if current_interactable and Input.is_action_just_pressed("interact"):
		# Play action sound
		if action_sound:
			AudioManager.play_sfx(action_sound)
		
		# Existing interaction calls
		if current_interactable.has_method("_give_random_item"):
			current_interactable._give_random_item()
		elif current_interactable.has_method("_deposit_and_spawn"):
			current_interactable._deposit_and_spawn()

func register_interactable(interactable_node: Node):
	if interactable_node not in nearby_interactables:
		nearby_interactables.append(interactable_node)
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
func _normalize_item_name(x) -> String:
	# Accept strings or dicts and normalize to lowercase, trimmed string
	if typeof(x) == TYPE_DICTIONARY and x.has("name"):
		x = x["name"]
	return str(x).strip_edges().to_lower()

func has_items(required_items: Array) -> bool:
	# required_items may be array of strings OR array of dicts { "name": "..." }
	for req in required_items:
		var want_name = _normalize_item_name(req)

		var found := false
		for inv_item in inventory:
			var inv_name = _normalize_item_name(inv_item)
			if inv_name == want_name:
				found = true
				break
		if not found:
			# debug: show what failed
			print("Player.has_items: missing ->", want_name, "inventory:", inventory)
			return false
	return true

func remove_items(items_to_remove: Array) -> void:
	# Remove one matching instance per requested item (works with dicts or strings)
	for rem in items_to_remove:
		var want_name = _normalize_item_name(rem)

		# iterate backwards so remove_at is safe
		var removed := false
		for i in range(inventory.size() - 1, -1, -1):
			var inv_name = _normalize_item_name(inventory[i])
			if inv_name == want_name:
				inventory.remove_at(i)
				removed = true
				break
		if not removed:
			# debug: couldn't find one to remove (shouldn't happen if has_items was used first)
			print("Player.remove_items: couldn't remove", want_name, "inventory currently:", inventory)

func add_item(item_name: String):
	# Keep the stored inventory as the original string (not normalized) to preserve display,
	# but the comparison functions above will match case-insensitively.
	inventory.append(item_name)
	print("Picked up:", item_name)
	
	if item_pickup_sound:
		AudioManager.play_sfx(item_pickup_sound)

func print_inventory():
	print("=== Player Inventory ===")
	for item in inventory:
		print(" - ", item)
