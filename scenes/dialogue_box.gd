extends Node2D

const CHAR_READ_RATE = .05
var tween: Tween

@onready var textbox_container = $TextboxContainer
@onready var start_symbol = $TextboxContainer/MarginContainer/HBoxContainer/StartSymbol
@onready var end_symbol = $TextboxContainer/MarginContainer/HBoxContainer/EndSymbol
@onready var text = $TextboxContainer/MarginContainer/HBoxContainer/VScrollBar/Text
#@onready var speaker = $SpeakerLabel

var speaker_queue := []

func _ready():
	show_textbox()
	print("text me right noiw or soeting")
	Trigger_Dialogue("This is the texting words", "aryana")
	Trigger_Dialogue("meow meowmeow meowmeow meowmeow meowmeow meowmeow meowmeow meowmeow meow", "Aryana")
	#text.queue_text("meow meow meow meoal;skdfj;alksdjf;laksdjf;lkajsdf;lkjasd;flkajsdf;lkajsdf;lkasjdfw meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow ya ya ya ya poop poop poop poop then i")
	text.dialogue_empty.connect(_on_dialogue_empty)
	#hide_textbox()
	
func Trigger_Dialogue(speaker: String, dialogue: String):
	print("dialogue trig")
	text.queue_text(dialogue, speaker)
	
func _on_dialogue_empty():
	self.hide()
	
func hide_textbox():
	start_symbol.text = ""
	end_symbol.text = ""
	text.text  = ""
	textbox_container.hide()
	
func show_textbox():
	start_symbol.text = "*"
	textbox_container.show()
	
