extends Node

# --- Nodes ---
@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	# Add players to the scene tree
	add_child(sfx_player)
	add_child(music_player)
	music_player.stream_paused = false
	music_player.autoplay = true

# Play a one-shot sound effect
func play_sfx(sound: AudioStream):
	if sound:
		sfx_player.stream = sound
		sfx_player.volume_db = -30  # Set SFX volume
		sfx_player.play()

# Play looping background music
func play_music(music: AudioStream):
	if music:
		music_player.stream = music
		music_player.volume_db = -30  # Set volume to -30 dB
		music_player.play()

# Stop music
func stop_music():
	music_player.stop()
