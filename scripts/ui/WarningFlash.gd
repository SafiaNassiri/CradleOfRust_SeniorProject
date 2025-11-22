extends ColorRect

@export var flash_color: Color = Color(1,0,0,0.5)
@export var flash_speed: float = 5.0
var is_flashing: bool = false
var target_alpha: float = 0.0

func start_flashing():
	is_flashing = true

func stop_flashing():
	is_flashing = false
	color.a = 0.0

func _process(_delta):
	if is_flashing:
		# Godot 4 replacement for OS.get_ticks_msec()
		target_alpha = 0.3 + 0.2 * sin(Time.get_ticks_msec() / 100.0)
		color = Color(flash_color.r, flash_color.g, flash_color.b, target_alpha)
