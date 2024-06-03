extends Node

signal object_picked(obj_id)

var CAMERA_SENSITIVITY : int = 5
var CURSOR_MODE_ENABLED: bool = false



func _physics_process(delta):
	if Input.is_action_just_pressed("cursor_toggle"):
		if !CURSOR_MODE_ENABLED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		CURSOR_MODE_ENABLED = !CURSOR_MODE_ENABLED
	
