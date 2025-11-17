extends Node2D

@export var respawn_times := { "common": 3.0, "uncommon": 6.0, "rare": 12.0, "legendary": 20.0 }
@export var scavenge_scene: PackedScene  # assign your ScavengeObject scene here

var scavenge_instance: Node2D = null

func _ready():
	spawn_item()

func spawn_item():
	if scavenge_scene == null:
		print("No ScavengeObject assigned!")
		return

	scavenge_instance = scavenge_scene.instantiate()
	add_child(scavenge_instance)
	scavenge_instance.global_position = global_position

	# Connect respawn signal
	scavenge_instance.connect("respawn_needed", Callable(self, "_on_item_collected"))

func _on_item_collected(rarity: String) -> void:
	# Remove current instance
	if is_instance_valid(scavenge_instance):
		scavenge_instance.queue_free()
		scavenge_instance = null

	# Delay respawn based on rarity
	var delay = respawn_times.get(rarity, 5.0)
	var timer = get_tree().create_timer(delay)
	await timer.timeout
	spawn_item()
