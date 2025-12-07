extends Control

@export var world_state_path: NodePath

@onready var stability_bar: ProgressBar = $StatsVBox/StabilityRow/StabilityBar
@onready var trust_bar: ProgressBar     = $StatsVBox/TrustRow/TrustBar
@onready var morality_bar: ProgressBar  = $StatsVBox/MoralityRow/MoralityBar

var world_state: Node = null

func _ready():
	if world_state_path != NodePath("") and has_node(world_state_path):
		world_state = get_node(world_state_path)

	# Initialize from current values
	_update_from_world()

func _process(_delta: float) -> void:
	# Simple polling; later you could switch to signals.
	_update_from_world()

func _update_from_world():
	if world_state == null:
		return

	stability_bar.value = world_state.facility_stability
	trust_bar.value     = world_state.ai_trust
	morality_bar.value  = world_state.morality
