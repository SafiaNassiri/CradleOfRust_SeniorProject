extends CanvasLayer
class_name AINarratorHUD

@export var max_trust := 100
@export var min_trust := 0
@export var trust_change_speed := 0.5  # seconds for the bar to update

@onready var ai_icon: TextureRect = $AIIcon
@onready var trust_indicator: ColorRect = $TrustIndicator
@onready var dialogue_box = null

var trust: float = 100
#var _current_indicator_value: float = 100.0

# Prototype AI lines
var high_trust_lines := [
	"You're doing great. Keep it up!",
	"I knew I could rely on you.",
	"Facility stability looks excellent thanks to your work.",
	"You’re efficient… impressive.",
	"Your cooperation makes all the difference."
]

var low_trust_lines := [
	"This is unacceptable… I expected more.",
	"I don't trust your decisions right now.",
	"Facility conditions are deteriorating… you must act.",
	"You need to prove you can handle responsibility.",
	"Your negligence could cost everything."
]

func _ready():
	var ws = get_tree().current_scene.get_node("===WorldState===")
	if ws:
		ws.connect("ai_trust_changed", Callable(self, "set_trust"))

# -------------------------
# Trust Update
# -------------------------
func set_trust(value: float) -> void:
	trust = clamp(value, min_trust, max_trust)

	# Smoothly update the ColorRect's color (and optionally size)
	_update_indicator_smooth()

# -------------------------
# Smooth Indicator Update
# -------------------------
func _update_indicator_smooth() -> void:
	var t_target = trust / max_trust
	var color_target = Color(1 - t_target, t_target, 0.0)  # red -> green

	var tween = get_tree().create_tween()
	tween.tween_property(trust_indicator, "color", color_target, trust_change_speed)

func say_ai(lines: Array) -> void:
	if dialogue_box:
		dialogue_box.play_cutscene([{ "speaker": "AI", "lines": lines }])
