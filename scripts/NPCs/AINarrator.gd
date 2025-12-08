extends Node

signal finished_cutscene
signal finished_line

@export var typing_speed: float = 0.03
@onready var dialogue_box = null
@onready var ai_name := "A.I. UNIT-04"

var is_playing := false


# -------------------------
# PUBLIC API
# -------------------------
func say_ai(lines: Array) -> void:
	if is_playing: return
	is_playing = true
	await _play_lines(lines, ai_name)


func say_narrator(lines: Array) -> void:
	if is_playing: return
	is_playing = true
	await _play_lines(lines, "NARRATOR")


func play_cutscene(seq: Array) -> void:
	if is_playing: return
	is_playing = true
	await _play_cutscene(seq)
	emit_signal("finished_cutscene")
	is_playing = false


# -------------------------
# INTERNAL FUNCTIONS
# -------------------------
func _play_lines(lines: Array, speaker: String) -> void:
	for line in lines:
		await _show_text(speaker, line)

	emit_signal("finished_line")
	is_playing = false


func _show_text(speaker: String, line: String) -> void:
	dialogue_box.visible = true
	dialogue_box.set_speaker(speaker)
	dialogue_box.clear()

	# Typewriter effect
	for c in line:
		dialogue_box.append(c)
		await get_tree().create_timer(typing_speed).timeout

	# Wait for player to press "continue"
	await dialogue_box.wait_for_next()

	dialogue_box.clear()


func _play_cutscene(seq: Array) -> void:
	for block in seq:
		var speaker: String = block.get("speaker", "NARRATOR")
		var lines: Array = block.get("lines", [])

		if speaker == "AI":
			await say_ai(lines)
		else:
			await say_narrator(lines)
