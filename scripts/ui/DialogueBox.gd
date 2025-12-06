extends CanvasLayer

signal finished_line

@onready var speaker_label = $SpeakerLabel
@onready var text_label = $TextLabel

@export var typing_speed := 0.03

var is_typing := false
var skip_typing := false

func play_cutscene(seq: Array) -> void:
	visible = true
	for block in seq:
		var speaker = block.get("speaker", "NARRATOR")
		var lines = block.get("lines", [])
		for line in lines:
			await _type_line(line, speaker)
	visible = false

func _type_line(line: String, speaker: String) -> void:
	if text_label:
		text_label.clear()  # Works for RichTextLabel
	if speaker_label:
		speaker_label.text = speaker
	
	is_typing = true
	skip_typing = false
	
	for c in line:
		if text_label:
			text_label.append_text(c)  # Use append_text, not append_bbcode
		var t := 0.0
		while t < typing_speed:
			await get_tree().process_frame
			t += get_process_delta_time()
			if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("interact"):
				skip_typing = true
				break
		if skip_typing:
			break
	
	if skip_typing and text_label:
		text_label.text = line
	
	is_typing = false
	emit_signal("finished_line")
