extends Label

@onready var speaker_label = $"../../../../../SpeakerLabel"

const CHAR_READ_RATE := 0.05  # seconds per character
signal dialogue_empty

var full_text := ""
var current_speaker := ""
var typing := false
var typing_finished = false

var text_queue := []
var speaker_queue := []

# Call this to add lines to the queue
func queue_text(new_text: String, new_speaker: String) -> void:
	text_queue.append(new_text)
	speaker_queue.append(new_speaker)
	typing_finished = false
	if not typing:
		print("PROCESSINGNGNGNG")
		_process_queue()


	
# Internal function to process the queue
func _process_queue() -> void:
	if text_queue.is_empty():
		print("empty aurgh?")
		return
	
	typing = true
	full_text = text_queue.pop_front()
	current_speaker = speaker_queue.pop_front()
	text = ""
	
	var hold = full_text
	full_text = current_speaker
	current_speaker = hold
	
	print("speaker")
	print(current_speaker)
	print("text")
	print(full_text)
	
	speaker_label.text = current_speaker
	
	await get_tree().create_timer(0.2).timeout
	# typewriter style
	for i in range(1, full_text.length() + 1):
		text = full_text.substr(0, i)	
		# if click to skip typwriteer style
		if(_process_input()):
			text = full_text
			await get_tree().create_timer(CHAR_READ_RATE).timeout
			await get_tree().create_timer(0.2).timeout
			await _wait_for_input()
			break
		await get_tree().create_timer(CHAR_READ_RATE).timeout
	await _wait_for_input()
	
	if not text_queue.is_empty():
		typing_finished = false
		_process_queue()
	else:
		typing = false
		emit_signal("dialogue_empty")
		return 



# input to go onto next dialogue
func _wait_for_input() -> void:
	var input_received = false
	while not input_received:
		await get_tree().process_frame  # wait a frame
		if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT):
			input_received = true

# input during typewriter style, allowing to skip it
func _process_input():
	if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MouseButton.MOUSE_BUTTON_LEFT):
		return true
	return false
