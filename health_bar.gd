extends Node2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var p_stats = player.stats

var health = p_stats.max_health
var stam = p_stats.max_stamina

func _ready():
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if not player:
		push_error("No Player found")
		return

	p_stats = player.stats
	if not p_stats:
		push_error("Player.stats is null")
		return

	# connect signlas
	p_stats.health_updated.connect(_update_health_bar)
	p_stats.stamina_changed.connect(_update_stamina_bar)

	#p_stats.stamina_changed.connect(self.set_stamina_bar)
#	p_stats.health_changed.connect(self.set_health_bar)

	$HealthBar.max_value = p_stats.max_health
	$StaminaBar.max_value = p_stats.max_stamina
	set_health_bar()
	set_stamina_bar()
	
	$TestDamage.pressed.connect(_test_damage)


# Stamina bar
func set_stamina_bar(new_stamina = null):
	if new_stamina != null:
		$StaminaBar.value = new_stamina
	else:
		$StaminaBar.value = p_stats.stamina

# health bar
#func set_health_bar(new_health = null):
func set_health_bar():
	$HealthBar.value = health
	#if new_health != null:
	#	$HealthBar.value = new_health
	#else:
	#	$HealthBar.value = p_stats.health

func _update_health_bar(new_health):
	$HealthBar.value = new_health

func _update_stamina_bar(new_stamina):
	$StaminaBar.value = new_stamina


func set_health_label():
	$HealthBar.value = health




# health bar damage -- rellocation when enemies/damage is implemented?
func _input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		print("hello")
		damage()
	
func damage():
	print("HELLO")
	health -= 10
	if health <= 0:
		health = player.stats.max_health
	set_health_label()
	set_health_bar()
	

	
	
# do not keep: for testing purposes
func _test_damage():
	damage()
