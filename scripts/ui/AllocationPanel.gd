# res://scripts/AllocationPanel.gd
extends CanvasLayer

# exported so you can set in editor or from code
@export var total_resources: int = 0:
	set = set_total_resources

# Node references
@onready var panel = $PanelContainer
@onready var title_label = $PanelContainer/VBoxContainer/HBoxContainer/TitleLabel
@onready var progress_bar = $PanelContainer/VBoxContainer/ProgressBar
@onready var total_label = $PanelContainer/VBoxContainer/TotalRow/TotalLabel
@onready var repair_slider = $PanelContainer/VBoxContainer/RepairRow/RepairSlider
@onready var self_slider = $PanelContainer/VBoxContainer/SelfRow/SelfSlider
@onready var remaining_label = $PanelContainer/VBoxContainer/RemainingLabel
@onready var commit_button = $PanelContainer/VBoxContainer/Buttons/CommitButton

signal allocation_committed(repair_amount: int, self_amount: int)

func _ready():
	# Ensure integer steps on sliders
	repair_slider.step = 1
	self_slider.step = 1
	repair_slider.min_value = 0
	self_slider.min_value = 0

	# Connect signals (explicit connect ensures we can check which changed)
	repair_slider.value_changed.connect(_on_repair_changed)
	self_slider.value_changed.connect(_on_self_changed)
	commit_button.pressed.connect(_on_commit_pressed)

	# Hide by default; show via show_panel()
	hide()

func set_total_resources(value: int) -> void:
	total_resources = max(0, value)
	_apply_total_to_sliders()
	_update_labels()

# called when you want to display the panel
func show_panel(gathered_amount: int) -> void:
	set_total_resources(gathered_amount)
	title_label.text = "Allocate Scrap (" + str(gathered_amount) + " available)"
	show()
	# optionally focus first control
	repair_slider.grab_focus()

func _apply_total_to_sliders() -> void:
	# Full range for each slider is 0..total_resources,
	# but we dynamically manage the other's max so combined values never exceed total.
	repair_slider.max_value = total_resources
	self_slider.max_value = total_resources

	# clamp current values
	repair_slider.value = clamp(int(repair_slider.value), 0, total_resources)
	self_slider.value = clamp(int(self_slider.value), 0, total_resources)

func _on_repair_changed(new_value: float) -> void:
	var repair_val = int(new_value)
	# other slider max allowed = total_resources - repair_val
	var other_max = max(0, total_resources - repair_val)
	# if self_slider.value > allowed, reduce it
	if int(self_slider.value) > other_max:
		self_slider.block_signals = true
		self_slider.value = other_max
		self_slider.block_signals = false
	self_slider.max_value = other_max
	_update_labels()

func _on_self_changed(new_value: float) -> void:
	var self_val = int(new_value)
	var other_max = max(0, total_resources - self_val)
	if int(repair_slider.value) > other_max:
		repair_slider.block_signals = true
		repair_slider.value = other_max
		repair_slider.block_signals = false
	repair_slider.max_value = other_max
	_update_labels()

func _update_labels() -> void:
	var allocated = int(repair_slider.value) + int(self_slider.value)
	var remaining = total_resources - allocated
	total_label.text = str(total_resources)
	remaining_label.text = "Remaining: " + str(remaining)
	# update progress bar: percent of allocated / total (guard divis by 0)
	if total_resources > 0:
		progress_bar.value = float(allocated) / float(total_resources) * 100.0
	else:
		progress_bar.value = 0

func _on_commit_pressed() -> void:
	var repair_amount = int(repair_slider.value)
	var self_amount = int(self_slider.value)
	emit_signal("allocation_committed", repair_amount, self_amount)
	hide()
