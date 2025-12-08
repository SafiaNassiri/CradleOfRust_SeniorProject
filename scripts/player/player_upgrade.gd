extends Control

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var inventory = get_tree().get_first_node_in_group("Inventory")
var price = 5
var health_increase = 50
var stamina_increase = 50
var recover_increase = 25


func _ready():
	$CanvasLayer/Panel/HealthB.pressed.connect(on_first_button)
	$CanvasLayer/Panel/StamB.pressed.connect(on_second_button)
	$CanvasLayer/Panel/RecB.pressed.connect(on_third_button)

func purchase_upgrade(upgrade_id):
	print(inventory.count)
	if inventory.count >= price and upgrade_id == 1:
		upgrade_max_health()
	elif inventory.count >= price and upgrade_id == 2:
		upgrade_max_stamina()
	elif inventory.count >= price and upgrade_id == 3:
		upgrade_stamina_recovery()

func on_first_button():	
	purchase_upgrade(1)
	
func on_second_button():
	purchase_upgrade(2)
	
func on_third_button():
	purchase_upgrade(3)
	
func upgrade_max_health():
	print("health")
	inventory.count -= price
	player.increase_max_health(health_increase)

func upgrade_max_stamina():
	print("stamina")
	inventory.count -= price
	player.increase_max_stamina(stamina_increase)

func upgrade_stamina_recovery():
	print("recover stamina")
	inventory.count -= price
	player.increase_stamina_recovery(recover_increase)
