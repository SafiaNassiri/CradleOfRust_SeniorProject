extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

var music_volume := 0.0  # in dB (-80 to 0)
var sfx_volume := 0.0

func _ready():
	music_player.volume_db = music_volume
	sfx_player.volume_db = sfx_volume

# -----------------------------
# Background Music
# -----------------------------
func play_music(stream: AudioStream, fade_in: bool = false):
	if stream == null:
		push_warning("Tried to play null music stream")
		return
	
	if fade_in:
		music_player.volume_db = -80
		music_player.stream = stream
		music_player.play()
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", music_volume, 2.0)
	else:
		music_player.stream = stream
		music_player.play()

func stop_music(fade_out: bool = false):
	if fade_out:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80, 2.0)
		await tween.finished
		music_player.stop()
		music_player.volume_db = music_volume
	else:
		music_player.stop()

func set_music_volume(volume_db: float):
	music_volume = clamp(volume_db, -80, 0)
	music_player.volume_db = music_volume

# -----------------------------
# Sound Effects
# -----------------------------
func play_sfx(stream: AudioStream):
	if stream == null:
		push_warning("Tried to play null SFX stream")
		return
	sfx_player.stream = stream
	sfx_player.play()

func set_sfx_volume(volume_db: float):
	sfx_volume = clamp(volume_db, -80, 0)
	sfx_player.volume_db = sfx_volume
