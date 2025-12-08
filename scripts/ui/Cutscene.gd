extends CanvasLayer

signal finished_cutscene

@onready var bg = $Background
@onready var speaker_label = $SpeakerLabel
@onready var text_label = $TextLabel
@onready var continue_prompt = $ContinuePrompt

@export var typing_speed := 0.03
@export var pause_after_line := 1.0

var is_typing := false
var skip_typing := false

# -------------------------
# Load from JSON
# -------------------------
func load_cutscene(file_path: String) -> Array:
	if not FileAccess.file_exists(file_path):
		push_error("Cutscene JSON not found: " + file_path)
		return []

	# Debug: indicate which cutscene file is being loaded
	print("[Cutscene Debug] Loading file:", file_path)

	var file = FileAccess.open(file_path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if data == null or typeof(data) != TYPE_DICTIONARY:
		push_error("Invalid JSON format in cutscene: " + file_path)
		return []

	return data.get("cutscene", [])                        

func play_cutscene(seq: Array) -> void:
	visible = true
	
	if bg:
		bg.visible = true
	if speaker_label:
		speaker_label.visible = true
	if text_label:
		text_label.visible = true
	else:
		push_error("TextLabel node not found!")
		return
	
	# Hide continue prompt since we're auto-advancing
	if continue_prompt:
		continue_prompt.visible = false
	
	for block in seq:
		var speaker = block.get("speaker", "NARRATOR")
		var lines = block.get("lines", [])
		
		if speaker_label:
			speaker_label.text = speaker
		
		for line in lines:
			await _type_line(line)
			# Pause briefly after line finishes
			await get_tree().create_timer(pause_after_line).timeout
	
	# Fade out after all lines are done
	await _fade_out()
	
	visible = false
	emit_signal("finished_cutscene")

func _type_line(line: String) -> void:

	if not text_label:
		return
		
	text_label.clear()
	is_typing = true
	skip_typing = false
	
	for c in line:
		text_label.append_text(c)
		
		# Allow skipping individual line typing
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("interact"):
			skip_typing = true
			break
		
		await get_tree().create_timer(typing_speed).timeout
	
	# If skipped, show the rest instantly
	if skip_typing:
		text_label.text = line
	
	is_typing = false

func _fade_out() -> void:
	# Fade out all child nodes
	var tween = get_tree().create_tween()
	tween.set_parallel(true)  # Fade everything at once
	
	if bg:
		tween.tween_property(bg, "modulate:a", 0.0, 1.0)
	if speaker_label:
		tween.tween_property(speaker_label, "modulate:a", 0.0, 1.0)
	if text_label:
		tween.tween_property(text_label, "modulate:a", 0.0, 1.0)
	if continue_prompt:
		tween.tween_property(continue_prompt, "modulate:a", 0.0, 1.0)
	
	await tween.finished
	
	# Reset modulate for next time
	if bg:
		bg.modulate.a = 1.0
	if speaker_label:
		speaker_label.modulate.a = 1.0
	if text_label:
		text_label.modulate.a = 1.0
	if continue_prompt:
		continue_prompt.modulate.a = 1.0
