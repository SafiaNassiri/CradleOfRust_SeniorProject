extends CanvasLayer

@export var fade_speed: float = 2.0
var alpha: float = 0.0
@onready var overlay: ColorRect = $ColorRect

func _ready():
	overlay.color.a = 0.0
	set_process(true)

func _process(delta):
	if alpha < 1.0:
		alpha += fade_speed * delta
		overlay.color.a = clamp(alpha, 0, 1)
