extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


@export var joystick : Node2D
@export var camera_drag: Control
@export var jump_btn: Node
@export var crosshair: Node
@export var fire_btn: Node

@onready var pistol = $CameraPivot/GunPivot/Pistol
@onready var animation_player = $AnimationPlayer
@onready var camera_3d = $CameraPivot/Camera3D

var CAMERA_INIT_POSITION: Vector3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	set_platform_configurations()
	CAMERA_INIT_POSITION = camera_3d.position
	
func _physics_process(delta):
	handle_inputs(delta)

	


func handle_inputs(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	

	
		
	var input_dir
	if OS.get_name() == "Android":
		if joystick.has_method("get_direction"):
			input_dir = joystick.get_direction()
	else:
		input_dir = Input.get_vector("left", "right", "up", "down")
		if Input.is_action_just_pressed("fire"):
			pistol.fire_bullet()
		
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		animation_player.play("moving")
		if !crosshair.spread_played:
			crosshair.play_spread()
			crosshair.spread_played = true
			
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		animation_player.stop(true)
		camera_3d.position = lerp(camera_3d.position, CAMERA_INIT_POSITION, .15)
		if crosshair.spread_played:
			crosshair.play_spread_backwards()
			crosshair.spread_played = false
		
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
func _on_camera_drag_gui_input(event):
	if event is InputEventScreenDrag:
		self.rotation.y -= event.relative.x/1000*Manager.CAMERA_SENSITIVITY


func set_platform_configurations():
	if OS.get_name() == "Android":
		joystick.show()
		camera_drag.show()
		jump_btn.show()
		fire_btn.show()
	else:
		joystick.hide()
		camera_drag.hide()
		jump_btn.hide()
		fire_btn.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event):
	if OS.get_name() == "Windows":
		if event is InputEventMouseMotion:
			self.rotation.y -= event.relative.x/1000*Manager.CAMERA_SENSITIVITY


func _on_jump_pressed():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY


func _on_fire_pressed():
	pistol.fire_bullet()
