extends Node2D

@export var required_items = []

@onready var prompt_panel: Control = $PromptPanel
@onready var item_container: HBoxContainer = $PromptPanel/HBoxContainer

var can_interact := false
var player_ref: Node = null
var interaction_menu: CanvasLayer = null  # Changed from Control to CanvasLayer

func _ready():
	# Pick 3 random items from the database for this terminal
	required_items = ItemDatabase.get_random_items(3)
	_update_prompt_panel()
	prompt_panel.visible = false
	
	# Get reference to the SHARED menu in the UI layer
	interaction_menu = get_tree().current_scene.get_node_or_null("===UI===/TerminalInteractionMenu")
	
	if not interaction_menu:
		push_error("TerminalInteractionMenu not found in ===UI===!")
	
	# Connect Area2D signals
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))
	$Area2D.connect("body_exited", Callable(self, "_on_body_exited"))

func _process(_delta):
	if can_interact and Input.is_action_just_pressed("interact"):
		_show_interaction_menu()

# -------------------------
# Prompt panel
# -------------------------
func _update_prompt_panel():
	for child in item_container.get_children():
		child.queue_free()
	
	for item_name in required_items:
		var icon_texture = ItemDatabase.get_icon(item_name)
		if icon_texture:
			var tex_rect = TextureRect.new()
			tex_rect.texture = icon_texture
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_rect.custom_minimum_size = Vector2(32, 32)
			item_container.add_child(tex_rect)

# -------------------------
# Interaction Menu
# -------------------------
func _show_interaction_menu():
	if not interaction_menu:
		return
	
	# Disconnect any previous signals to avoid duplicates
	var btn_all = interaction_menu.get_node("Panel/HBoxContainer/BtnGiveAll")
	var btn_two = interaction_menu.get_node("Panel/HBoxContainer/BtnGiveTwo")
	var btn_none = interaction_menu.get_node("Panel/HBoxContainer/BtnGiveNone")
	
	if btn_all.is_connected("pressed", Callable(self, "_on_give_all")):
		btn_all.disconnect("pressed", Callable(self, "_on_give_all"))
	if btn_two.is_connected("pressed", Callable(self, "_on_give_two")):
		btn_two.disconnect("pressed", Callable(self, "_on_give_two"))
	if btn_none.is_connected("pressed", Callable(self, "_on_give_none")):
		btn_none.disconnect("pressed", Callable(self, "_on_give_none"))
	
	# Connect THIS terminal's callbacks
	btn_all.connect("pressed", Callable(self, "_on_give_all"))
	btn_two.connect("pressed", Callable(self, "_on_give_two"))
	btn_none.connect("pressed", Callable(self, "_on_give_none"))
	
	# Position menu at center of screen or near terminal
	# interaction_menu.global_position = global_position + Vector2(-100, -200)
	
	interaction_menu.visible = true
	
	# Pause player
	if player_ref:
		player_ref.set_physics_process(false)
		player_ref.set_process_input(false)

func _hide_interaction_menu():
	if interaction_menu:
		interaction_menu.visible = false
	
	# Resume player
	if player_ref:
		player_ref.set_physics_process(true)
		player_ref.set_process_input(true)

# -------------------------
# Button Callbacks
# -------------------------
func _on_give_all():
	print("Terminal: Give All to ", name)
	if player_ref and player_ref.has_method("has_items") and player_ref.has_method("remove_items"):
		if player_ref.has_items(required_items):
			player_ref.remove_items(required_items)
			print("✓ Deposited all 3 items to ", name)
			_complete_terminal()
		else:
			print("✗ Player doesn't have all required items")
	_hide_interaction_menu()

func _on_give_two():
	print("Terminal: Give 2 items to ", name)
	if player_ref and player_ref.has_method("has_items") and player_ref.has_method("remove_items"):
		var two_items = required_items.slice(0, 2)
		if player_ref.has_items(two_items):
			player_ref.remove_items(two_items)
			print("✓ Deposited 2 items to ", name)
			# Partial trust penalty
			var ai_hud = get_tree().current_scene.get_node_or_null("===UI===/AINarratorHUD")
			if ai_hud:
				ai_hud.set_trust(ai_hud.trust - 5)
		else:
			print("✗ Player doesn't have enough items")
	_hide_interaction_menu()

func _on_give_none():
	print("Terminal: Give None to ", name)
	
	# Trust penalty
	var ai_hud = get_tree().current_scene.get_node_or_null("===UI===/AINarratorHUD")
	if ai_hud:
		ai_hud.set_trust(ai_hud.trust - 10)
	
	_hide_interaction_menu()

func _complete_terminal():
	prompt_panel.visible = false
	can_interact = false
	print("Terminal ", name, " completed!")

# -------------------------
# Area2D triggers
# -------------------------
func _on_body_entered(body):
	if body.is_in_group("player"):
		can_interact = true
		player_ref = body
		prompt_panel.visible = true
		_update_prompt_panel()

func _on_body_exited(body):
	if body.is_in_group("player"):
		can_interact = false
		player_ref = null
		prompt_panel.visible = false
		_hide_interaction_menu()
