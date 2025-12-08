extends Control

@export var load_scene : PackedScene
@export var in_time  : float = 0.5
@export var fade_in_time : float = 1
@export var pause_time : float = 1.5
@export var fade_out_time : float = 1
@export var out_time : float = 0.5
@export var splash_screen : TextureRect

func _ready() -> void:
	# Play intro music during splash
	AudioManager.set_music_volume(-30) 
	var splash_music = preload("res://assets/Audio/338367__cabled_mess__deep-04-low-rumbling-drone.wav")
	AudioManager.play_music(splash_music)
	fade()

func fade() -> void:
	splash_screen.modulate.a = 0.0
	var tween = self.create_tween()
	tween.tween_interval(in_time)
	tween.tween_property(splash_screen, "modulate:a", 1.0, fade_in_time)
	tween.tween_interval(pause_time)
	tween.tween_property(splash_screen, "modulate:a", 0.0, fade_out_time)
	await tween.finished
	get_tree().change_scene_to_packed(load_scene)
