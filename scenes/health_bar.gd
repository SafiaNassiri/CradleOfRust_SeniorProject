extends Node2D

var player = null
var p_stats = null

#var health = p_stats.max_health
#var stam = p_stats.max_stamina
const MAX_HEALTH = 100
var health = MAX_HEALTH

func _ready():
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("Player")
	print(player)
	set_process(true)
	
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("Player")
	if not player:
		push_error("No Player found")
		return

	p_stats = player.stats
	if not p_stats:
		push_error("Player.stats is null")
		return

	# connect signlas
	p_stats.stamina_changed.connect(self.set_stamina_bar)
#	p_stats.health_changed.connect(self.set_health_bar)

	$HealthBar.max_value = p_stats.max_health
	$StaminaBar.max_value = p_stats.max_stamina
	set_health_bar()
	set_stamina_bar()
	
	$TestDamage.pressed.connect(_test_damage)

func _process(delta):
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player != null:
			p_stats = player.stats
			set_process(false)

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
