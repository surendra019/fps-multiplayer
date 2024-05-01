@tool
extends Panel

signal pressed

@onready var label = $Label

@export var button_name : String
@export_range(0.0, 1.0) var _transparency: float = 1.0

func _gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			pressed.emit()

func _physics_process(delta):
	label.text = button_name
	self.modulate.a = _transparency
