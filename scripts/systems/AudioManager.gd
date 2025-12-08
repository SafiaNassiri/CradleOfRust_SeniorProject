extends Node

#@onready var music_player: AudioStreamPlayer = $MusicPlayer
#@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

var music_volume := 0.0
var sfx_volume := 0.0
#
#func _ready():
	#music_player.volume_db = music_volume
	#sfx_player.volume_db = sfx_volume

# -----------------------------
# Background Music
# -----------------------------
#func play_music(stream: AudioStream):
	#if stream == null:
		#return
	#music_player.stream = stream
	#music_player.play()
#
#func stop_music():
	#music_player.stop()
#
## -----------------------------
## Sound Effects
## -----------------------------
#func play_sfx(stream: AudioStream):
	#if stream == null:
		#return
	#sfx_player.stream = stream
	#sfx_player.play()
