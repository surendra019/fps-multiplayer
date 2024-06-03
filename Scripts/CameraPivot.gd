extends Node3D

var player

var current_camera
@onready var camera_3d = $Camera3D


func _ready():
	current_camera = camera_3d
	player = get_parent()

func _on_camera_drag_gui_input(event):
	if event is InputEventScreenDrag:
		self.rotation.x = clamp(self.rotation.x-(event.relative.y)/1000*Manager.CAMERA_SENSITIVITY, -.9, .83)
	
func _input(event):
	if OS.get_name() == "Windows":
		if !Manager.CURSOR_MODE_ENABLED:
			if event is InputEventMouseMotion:
				self.rotation.x = clamp(self.rotation.x-(event.relative.y)/1000*Manager.CAMERA_SENSITIVITY, -.9, .83)


func get_target_position():
	var pos: Vector3
	var start = current_camera.project_ray_origin(player.crosshair.global_position)
	var end = current_camera.project_position(player.crosshair.global_position, 1000)
	pos = end
	
	var param = PhysicsRayQueryParameters3D.new()
	param.from = start
	param.to = end
	
	var result = get_world_3d().direct_space_state.intersect_ray(param)

	if result.size() > 0:
		pos = result.position
	return pos
