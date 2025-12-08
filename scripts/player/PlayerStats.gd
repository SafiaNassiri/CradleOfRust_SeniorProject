extends Node

# -------------------------
# Core Stats
# -------------------------
var max_health: float = 100.0
var health: float = max_health
var max_stamina: float = 100.0
var stamina: float = max_stamina
var scrap: int = 0

# World State Variables
@export_range(0.0, 100.0, 1.0) var facility_stability: float = 100.0  # E
@export_range(0.0, 100.0, 1.0) var ai_trust: float = 100.0            # T
@export_range(0.0, 100.0, 1.0) var morality: float = 100.0            # M

# Critical thresholds
const STABILITY_CRITICAL: float = 20.0
const TRUST_CRITICAL: float = 20.0

# Signals
signal stamina_changed(new_stamina)

# Upgrades / Modifiers
var upgrades = {
	"speed": 0,
	"stamina": 0,
	"efficiency": 0
}
var health_modifier: float = 0.0
var stamina_modifier: float = 0.0

# Signals
signal health_updated(new_health)
signal stability_updated(new_stability)
signal trust_updated(new_trust)
signal morality_updated(new_morality)
signal collapse_detected(reason: String)

# Health Functions
func Update_Health(amount: float) -> void:
	health += amount + health_modifier
	health = clamp(health, 0, max_health)
	emit_signal("health_updated", health)

func Is_Dead() -> bool:
	return health <= 0

# Stamina Functions
func Update_Stamina(amount: float) -> void:
	stamina += amount + stamina_modifier
	stamina = clamp(stamina, 0, max_stamina)
	emit_signal("stamina_changed", stamina)

func Can_Use_Stamina(amount: float) -> bool:
	return stamina >= amount

func Use_Stamina(amount: float) -> bool:
	if Can_Use_Stamina(amount):
		emit_signal("stamina_changed", stamina)
		Update_Stamina(-amount)
		return true
	return false

func Recover_Stamina(amount: float) -> void:
	Update_Stamina(amount)

# Scrap / Currency Functions
func Add_Scrap(amount: int) -> void:
	scrap += amount
	print(scrap)

func Spend_Scrap(amount: int) -> bool:
	if scrap >= amount:
		scrap -= amount
		return true
	return false

# Upgrade Functions
func Apply_Upgrade(upgrade_type: String, value: float) -> void:
	if upgrades.has(upgrade_type):
		upgrades[upgrade_type] += value
		match upgrade_type:
			"stamina":
				max_stamina += value
				stamina = min(stamina, max_stamina)

# World State Functions
func Update_Stability(change: float) -> void:
	facility_stability = clamp(facility_stability + change, 0, 100)
	emit_signal("stability_updated", facility_stability)
	Check_Collapse_State()

func Update_Trust(change: float) -> void:
	ai_trust = clamp(ai_trust + change, 0, 100)
	emit_signal("trust_updated", ai_trust)
	Check_Collapse_State()

func Update_Morality(change: float) -> void:
	morality = clamp(morality + change, 0, 100)
	emit_signal("morality_updated", morality)

func Check_Collapse_State() -> void:
	if facility_stability <= STABILITY_CRITICAL:
		emit_signal("collapse_detected", "Facility Stability too low!")
	elif ai_trust <= TRUST_CRITICAL:
		emit_signal("collapse_detected", "AI Trust too low!")

# Save / Load Functions
func Save_State() -> Dictionary:
	return {
		"health": health,
		"max_health": max_health,
		"stamina": stamina,
		"max_stamina": max_stamina,
		"scrap": scrap,
		"upgrades": upgrades.duplicate(true),
		"facility_stability": facility_stability,
		"ai_trust": ai_trust,
		"morality": morality
	}

func Load_State(state: Dictionary) -> void:
	if state.has("health"): health = state["health"]
	if state.has("max_health"): max_health = state["max_health"]
	if state.has("stamina"): stamina = state["stamina"]
	if state.has("max_stamina"): max_stamina = state["max_stamina"]
	if state.has("scrap"): scrap = state["scrap"]
	if state.has("upgrades"): upgrades = state["upgrades"].duplicate(true)
	if state.has("facility_stability"): facility_stability = state["facility_stability"]
	if state.has("ai_trust"): ai_trust = state["ai_trust"]
	if state.has("morality"): morality = state["morality"]

	# Notify UI
	emit_signal("health_updated", health)
	emit_signal("stability_updated", facility_stability)
	emit_signal("trust_updated", ai_trust)
	emit_signal("morality_updated", morality)

func Apply_Upgrade_ID(id: String) -> bool:
	# Read from SystemData
	var data = SystemData.player_upgrades.get(id)
	if data == null:
		push_error("Upgrade not found in SystemData: " + id)
		return false
		# First check cost
	var cost = data.get("cost", {})
	if not PlayerStorage.has_resources(cost):
		print("Not enough resources!")
		return false
	# Charge cost
	PlayerStorage.spend_resources(cost)
	# Apply effects
	if data.has("bonus_health"):
		max_health += data.bonus_health
		health = min(health, max_health)
	if data.has("bonus_stamina"):
		max_stamina += data.bonus_stamina
		stamina = min(stamina, max_stamina)
	if data.has("speed_upgrade"):
		upgrades["speed"] += data.speed_upgrade
	return true
