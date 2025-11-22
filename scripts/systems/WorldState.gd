extends Node

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
# Nodes
# -------------------------
@export var warning_flash_path: NodePath
@export var fade_overlay_path: NodePath
var warning_flash_node: Node = null
var fade_overlay: Node = null

# -------------------------
# Ready
# -------------------------
func _ready():
	if warning_flash_path != null and has_node(warning_flash_path):
		warning_flash_node = get_node(warning_flash_path)
	if fade_overlay_path != null and has_node(fade_overlay_path):
		fade_overlay = get_node(fade_overlay_path)

# -------------------------
# Update Functions
# -------------------------
func Update_Stability(change: float) -> void:
	facility_stability = clamp(facility_stability + change, 0, 100)
	print("DEBUG: Facility updated to", facility_stability)
	Check_Warning()
	Check_GameOver()

func Update_Trust(change: float) -> void:
	ai_trust = clamp(ai_trust + change, 0, 100)
	print("DEBUG: AI Trust updated to", ai_trust)
	Check_Warning()
	Check_GameOver()

func Update_Morality(change: float) -> void:
	morality = clamp(morality + change, 0, 100)
	print("DEBUG: Morality updated to", morality)
	Check_Warning()
	Check_GameOver()

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
	
	# Start fade overlay, then show Game Over scene
	if fade_overlay != null and fade_overlay.has_method("start_fade"):
		fade_overlay.visible = true
		fade_overlay.call("start_fade", reason)
	else:
		_show_game_over_scene(reason)

func _show_game_over_scene(_reason: String) -> void:
	# Remove current level scene
	if get_tree().current_scene != null:
		get_tree().current_scene.queue_free()
	
	# Load GameOver scene
	var scene = load("res://scenes/GameOver.tscn").instantiate()
	get_tree().current_scene = scene
	get_tree().paused = false
	print("Game Over Scene Loaded:", _reason)

# -------------------------
# Debug: Numpad Inputs
# -------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_KP_1, KEY_1:
				Update_Stability(-90)
				print("DEBUG: Facility set low!")
			KEY_KP_2, KEY_2:
				Update_Trust(-90)
				print("DEBUG: AI Trust set low!")
			KEY_KP_3, KEY_3:
				Update_Morality(-90)
				print("DEBUG: Morality set low!")
			KEY_KP_0, KEY_0:
				Update_Stability(100)
				Update_Trust(100)
				Update_Morality(100)
				print("DEBUG: World state reset!")
