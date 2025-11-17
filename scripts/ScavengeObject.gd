extends Node2D

@onready var area = $Area2D
var player_in_range := false

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false

func _process(delta):
	if player_in_range and Input.is_action_just_pressed("interact"): # 'E' key
		interact()

func interact():
	# Call backend scrap function
	Backend.Add_Scrap(1)

	# Remove or hide the scavenge object
	queue_free()
	# OR: visible = false
