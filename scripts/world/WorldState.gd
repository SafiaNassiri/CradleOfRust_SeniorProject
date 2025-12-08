extends Node

signal ai_trust_changed(new_trust: float) 

# -------------------------
# World Stats
# -------------------------
var facility_stability: float = 100.0
var ai_trust: float = 100.0
var morality: float = 100.0

# -------------------------
# Thresholds
# -------------------------
const STABILITY_WARNING: float = 25.0
const TRUST_WARNING: float = 25.0
const MORALITY_WARNING: float = 25.0

const STABILITY_CRITICAL: float = 0.0
const TRUST_CRITICAL: float = 0.0
const MORALITY_CRITICAL: float = 0.0

# -------------------------
# Nodes / NodePaths
# -------------------------
@export var warning_flash_path: NodePath
@export var fade_overlay_path: NodePath
@export var allocation_panel: NodePath   # <-- This remains a NodePath
@export var scrap_to_stability: float = 0.5
@export var scrap_to_morality: float = 0.3

var warning_flash_node: Node = null
var fade_overlay: Node = null
var allocation_panel_node: Node = null   # <-- The resolved node

# -------------------------
# Ready
# -------------------------
func _ready():

	# Resolve AllocationPanel node
	if allocation_panel != NodePath("") and has_node(allocation_panel):
		allocation_panel_node = get_node(allocation_panel)
		allocation_panel_node.hide()  # Start hidden

	#DEBUG
	print("SystemData:", SystemData)
	print("PlayerStorage:", PlayerStorage)
	
	if warning_flash_path != null and has_node(warning_flash_path):
		warning_flash_node = get_node(warning_flash_path)

	# Resolve FadeOverlay node
	if fade_overlay_path != NodePath("") and has_node(fade_overlay_path):
		fade_overlay = get_node(fade_overlay_path)


# -------------------------
# Update Functions
# -------------------------
func Update_Stability(change: float) -> void:
	facility_stability = clamp(facility_stability + change, 0, 100)
	print("DEBUG: Facility updated to", facility_stability)
	Check_Warning()
	Check_GameOver()
	Check_Dialogue_Triggers()

func Update_Trust(change: float) -> void:
	ai_trust = clamp(ai_trust + change, 0, 100)
	print("DEBUG: AI Trust updated to", ai_trust)

	# Emit signal
	emit_signal("ai_trust_changed", ai_trust)

	Check_Warning()
	Check_GameOver()
	Check_Dialogue_Triggers()

func Update_Morality(change: float) -> void:
	morality = clamp(morality + change, 0, 100)
	print("DEBUG: Morality updated to", morality)
	Check_Warning()
	Check_GameOver()
	Check_Dialogue_Triggers()


# -------------------------
# Warning Logic
# -------------------------
func Check_Warning() -> void:
	var low_stat = false

	if facility_stability <= STABILITY_WARNING:
		low_stat = true
	if ai_trust <= TRUST_WARNING:
		low_stat = true
	if morality <= MORALITY_WARNING:
		low_stat = true

	if low_stat:
		if warning_flash_node != null:
			warning_flash_node.call("start_flashing")
		print("⚠️ Warning: Low stat detected -> Facility:", facility_stability, "AI Trust:", ai_trust, "Morality:", morality)
	else:
		if warning_flash_node != null:
			warning_flash_node.call("stop_flashing")


# -------------------------
# Game Over Logic
# -------------------------
func Check_GameOver() -> void:
	if facility_stability <= STABILITY_CRITICAL:
		_trigger_game_over("Facility Collapsed")
	elif ai_trust <= TRUST_CRITICAL:
		_trigger_game_over("AI Rebellion")
	elif morality <= MORALITY_CRITICAL:
		_trigger_game_over("Morality Failed")

func _trigger_game_over(reason: String) -> void:
	print("GAME OVER:", reason)

	# Stop warning flash
	if warning_flash_node != null:
		warning_flash_node.call("stop_flashing")

	# Instead of fading to a separate Game Over scene, show cutscene in existing CanvasLayer
	_show_game_over_cutscene(reason)


func _show_game_over_cutscene(reason: String) -> void:
	var cutscene_layer = get_tree().current_scene.get_node("===UI===/CutsceneLayer")
	if not cutscene_layer:
		push_error("CutsceneLayer node not found at ===UI===/CutsceneLayer!")
		return

	var json_file := ""
	match reason:
		"Facility Collapsed":
			json_file = "res://data/cutscenes/failure_facility.json"
		"AI Rebellion":
			json_file = "res://data/cutscenes/failure_ai.json"
		"Morality Failed":
			json_file = "res://data/cutscenes/failure_morality.json"
		_:
			json_file = "res://data/cutscenes/failure_generic.json"

	# Debug: print which file is being used
	print("[GameOver Debug] Triggered cutscene:", reason, "-> JSON file:", json_file)

	var sequence = cutscene_layer.load_cutscene(json_file)

	# Connect signal to know when the cutscene finishes
	var callable_finished = Callable(self, "_on_cutscene_finished")
	if not cutscene_layer.is_connected("finished_cutscene", callable_finished):
		cutscene_layer.connect("finished_cutscene", callable_finished)
		
	cutscene_layer.play_cutscene(sequence)

func _on_cutscene_finished():
	print("Ending cutscene finished. Showing Game Over scene...")

	var tree = get_tree()
	if tree == null:
		push_error("_on_cutscene_finished: get_tree() is null! Cannot change scene.")
		return

	tree.change_scene_to_file("res://scenes/UI/GameOver.tscn")

# -------------------------
# Input Logic + Panel Toggle
# -------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_KP_1, KEY_1:
				Update_Stability(-5)  # decrement by 5 per press
				print("DEBUG: Facility decreased by 5 ->", facility_stability)
			KEY_KP_2, KEY_2:
				Update_Trust(-5)      # decrement by 5 per press
				print("DEBUG: AI Trust decreased by 5 ->", ai_trust)
			KEY_KP_3, KEY_3:
				Update_Morality(-5)   # decrement by 5 per press
				print("DEBUG: Morality decreased by 5 ->", morality)
			KEY_KP_0, KEY_0:
				Update_Stability(100)
				Update_Trust(100)
				Update_Morality(100)
				print("DEBUG: World state reset!")

	# Toggle Allocation Panel (default key: Q)
	if event.is_action_pressed("open_allocation"):
		if allocation_panel_node:
			if allocation_panel_node.visible:
				allocation_panel_node.hide()
			else:
				_show_allocation_panel()


func _show_allocation_panel():
	if allocation_panel_node:
		var gathered_amount := 0

		var player := get_tree().get_first_node_in_group("Player")
		if player and player.has_method("get_scrap"):
			gathered_amount = player.get_scrap()

		allocation_panel_node.show_panel(gathered_amount)

# -------------------------
# Handle Allocation Result
# -------------------------
func _on_allocation_committed(repair_amount: int, self_amount: int) -> void:
	var total_spent := repair_amount + self_amount

	var player := get_tree().get_first_node_in_group("Player")
	if player and player.stats and player.stats.Spend_Scrap(total_spent):
		var stability_delta := repair_amount * scrap_to_stability
		var morality_delta := self_amount * scrap_to_morality

		Update_Stability(stability_delta)
		Update_Morality(morality_delta)

		print("ALLOCATION COMMITTED:",
			"repair:", repair_amount,
			"self:", self_amount,
			"ΔStability:", stability_delta,
			"ΔMorality:", morality_delta)
	else:
		print("Not enough scrap to allocate!")
func Apply_Facility_Upgrade(id: String) -> bool:
	var data = SystemData.facility_upgrades.get(id)
	if data == null:
		push_error("Facility upgrade not found: " + id)
		return false
	# Check cost
	var cost = data.get("cost", {})
	if not PlayerStorage.has_resources(cost):
		print("Not enough resources for facility upgrade!")
		return false
	# Pay cost
	PlayerStorage.spend_resources(cost)
	# Apply effects
	if data.has("stability_bonus"):
		facility_stability = clamp(facility_stability + data.stability_bonus, 0, 100)
	if data.has("trust_bonus"):
		ai_trust = clamp(ai_trust + data.trust_bonus, 0, 100)
	if data.has("morality_bonus"):
		morality = clamp(morality + data.morality_bonus, 0, 100)
	# Trigger UI updates + warning check
	Check_Warning()
	Check_GameOver()
	return true

func Check_Dialogue_Triggers():
	for id in DialogueManager.events.keys():
		var ev = DialogueManager.get_event(id)
		var trig = ev.get("trigger")

		if trig.get("type") == "threshold":
			var stat = trig.get("stat")
			var cond = trig.get("condition")
			var value = trig.get("value")

			var current_val : float
			
			match stat:
				"facility_stability":
					current_val = facility_stability
				"ai_trust":
					current_val = ai_trust
				"morality":
					current_val = morality
				_:
					continue   # skip this event safely
			
			var passed := false
			
			match cond:
				"<=":
					passed = current_val <= value
				"<":
					passed = current_val < value
				">=":
					passed = current_val >= value
				">":
					passed = current_val > value
				"==":
					passed = current_val == value
				_:
					passed = false

			if passed:
				show_dialogue(id)

func show_dialogue(id: String):
	var lines = DialogueManager.get_lines(id)
	if lines.size() > 0:
		print("\n--- DIALOGUE EVENT:", id, "---")
		for line in lines:
			print(line)
		print("----------------------------\n")
