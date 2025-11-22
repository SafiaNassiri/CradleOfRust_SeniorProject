# Terminal.gd
extends Area2D

@export var required_items: Array[String] = [] # names of items the terminal wants
@export var possible_rewards: Array[PackedScene] = [] # items that can spawn as rewards
var can_interact := false
var player_ref: Node = null

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		can_interact = true
		player_ref = body
		show_prompt(true)

func _on_body_exited(body):
	if body.is_in_group("player"):
		can_interact = false
		player_ref = null
		show_prompt(false)

func _process(_delta):
	if can_interact and Input.is_action_just_pressed("interact") and player_ref:
		_try_deposit_items()

# Optional: show some UI prompt
func show_prompt(visible: bool):
	# You could show a Label above the terminal, e.g.,
	# $Prompt.visible = visible
	pass

func _try_deposit_items():
	# Check if player has all required items
	var inventory = player_ref.inventory if player_ref.has_method("inventory") else []
	var has_all := true

	for item_name in required_items:
		if not inventory.has(item_name):
			has_all = false
			break

	if has_all:
		# Remove items from player
		for item_name in required_items:
			inventory.erase(item_name) # removes first occurrence
		# Give rewards
		_spawn_rewards()
		print("Items deposited! Rewards spawned.")
	else:
		print("You don’t have all required items!")

func _spawn_rewards():
	if possible_rewards.size() == 0:
		return

	# Spawn 1-3 random rewards for example
	var reward_count = randi() % 3 + 1
	for i in reward_count:
		var reward_scene = possible_rewards[randi() % possible_rewards.size()]
		var reward_instance = reward_scene.instantiate()
		get_parent().add_child(reward_instance)
		# optionally position around the terminal
		reward_instance.position = global_position + Vector2(randi() % 32 - 16, randi() % 32 - 16)
