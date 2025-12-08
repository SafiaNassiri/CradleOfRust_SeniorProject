extends Control

@export var load_scene : PackedScene
@export var in_time  : float = 0.5
@export var fade_in_time : float = 1
@export var pause_time : float = 1.5
@export var fade_out_time : float = 1
@export var splash_screen_1 : TextureRect
@export var splash_screen_2 : TextureRect

func _ready():
	# Start background music
	var bg_music = load("res://assets/Audio/338367__cabled_mess__deep-04-low-rumbling-drone.wav")
	AudioManager.play_music(bg_music)

	await _fade_sequence()
	get_tree().change_scene_to_packed(load_scene)

# --------------------------
# Sequential fade
func _fade_sequence() -> void:
	# First splash
	splash_screen_1.visible = true
	splash_screen_1.modulate.a = 0.0
	var tween1 = create_tween()
	tween1.tween_property(splash_screen_1, "modulate:a", 1.0, fade_in_time)
	tween1.tween_interval(pause_time)
	tween1.tween_property(splash_screen_1, "modulate:a", 0.0, fade_out_time)
	await tween1.finished
	splash_screen_1.visible = false
	
	# Second splash
	splash_screen_2.visible = true
	splash_screen_2.modulate.a = 0.0
	var tween2 = create_tween()
	tween2.tween_property(splash_screen_2, "modulate:a", 1.0, fade_in_time)
	tween2.tween_interval(pause_time)
	tween2.tween_property(splash_screen_2, "modulate:a", 0.0, fade_out_time)
	await tween2.finished
	splash_screen_2.visible = false
