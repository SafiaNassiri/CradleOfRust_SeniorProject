extends Node

signal finished_cutscene
signal finished_line

@export var typing_speed := 0.03
@export var dialogue_box = $"../UI/DialogueBox"
@onready var ai_name := "A.I. UNIT-04"

var is_playing := false

func say_ai(lines: Array) -> void:
	if is_playing: return
	is_playing = true
	_play_lines(lines, ai_name)

func say_narrator(lines: Array) -> void:
	if is_playing: return
	is_playing = true
	_play_lines(lines, "NARRATOR")

func play_cutscene(seq: Array) -> void:
	if is_playing: return
	is_playing = true
	_play_cutscene(seq)

func _play_lines(lines: Array, speaker: String) -> void:
	for line in lines:
		yield(_show_text(speaker, line), "completed")
	emit_signal("finished_line")
	is_playing = false

func _show_text(speaker: String, lineL String) -> GDScriptFunctionState:
	dialogue_box.visible = true
	dialogue_box.set_speaker(speaker)
	dialogue_box.clear()
	
	for c in line:
		dialogue_box.append(c)
		await get_tree().create_timer(typing_speed).timeout
	await dialogue_box.wait_for_next()
	dialoge_box.clear()
	return GDScriptFunctionState.new()

func _play_cutscene(seq: Array) -> void:
	for block in seq:
		var speaker = block.get("speaker", "NARRATOR")
		var lines - block.get("lines", [])
		if speaker == "AI":
			yield(say_ai(lines), "finished_line")
		else:
			yield(say_narrator(lines), "finished_line")
	emit_signal("finished_cutscene")
	is_playing =false
