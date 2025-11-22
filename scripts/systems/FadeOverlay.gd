extends CanvasLayer

@export var fade_speed: float = 2.0
@onready var overlay: ColorRect = $ColorRect
var alpha: float = 0.0
var fading: bool = false
var game_over_reason: String = ""

func start_fade(reason: String) -> void:
	alpha = 0.0
	game_over_reason = reason
	fading = true
	overlay.color.a = 0.0
	visible = true
	set_process(true)

func _process(delta: float) -> void:
	if fading:
		alpha += fade_speed * delta
		overlay.color.a = clamp(alpha, 0, 1)
		if alpha >= 1.0:
			fading = false
			set_process(false)
			_show_game_over_scene()

func _show_game_over_scene() -> void:
	# Remove the current level scene
	var current = get_tree().current_scene
	if current != null:
		current.queue_free()

	# Load the GameOver scene
	var scene = load("res://scenes/GameOver.tscn").instantiate()
	get_tree().root.add_child(scene)
	get_tree().current_scene = scene
	print("Game Over Scene Loaded:", game_over_reason)
