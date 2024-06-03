extends CharacterBody3D


var SPEED = 5.0
const JUMP_VELOCITY = 4.5



@export var joystick : Node2D
@export var camera_drag: Control
@export var jump_btn: Node
@export var crosshair: Node
@export var fire_btn: Node
@export var ads_btn: Node
@onready var weapons = $UI/Weapons

@onready var pistol = $CameraPivot/GunPivot/Pistol
@onready var animation_player = $AnimationPlayer
@onready var camera_3d = $CameraPivot/Camera3D
@onready var ads_pivot = $CameraPivot/AdsPivot
@onready var ads_camera = $CameraPivot/AdsCamera
@onready var camera_pivot = $CameraPivot
@onready var gun_pivot = $CameraPivot/GunPivot
@onready var foot = $Foot
@onready var pickable_list = $UI/PickableList
@onready var secondary_gun_pivot = $CameraPivot/SecondaryGunPivot


var CAMERA_INIT_POSITION: Vector3
var enable_ads: bool

var near_objects = {}

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	set_platform_configurations()
	CAMERA_INIT_POSITION = camera_3d.position
	Manager.object_picked.connect(func(obj_id):
		pick_object(obj_id)
		)
	weapons.slot_selected.connect(func(gun):
		select_gun(gun)
		)
	if has_gun():
		get_current_gun().dropped = false
		weapons.add_gun(get_current_gun().head, get_current_gun())
	
func _physics_process(delta):
	handle_inputs(delta)

	
func get_obj_by_id(obj_id):
	return near_objects[obj_id]

func handle_inputs(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("ads"):
		if !Manager.CURSOR_MODE_ENABLED:
			toggle_ads()
	
	if Input.is_action_just_pressed("drop_gun"):
		drop_gun()
	if enable_ads:
		crosshair.hide()
		ads_camera.current = true
		camera_pivot.current_camera = ads_camera
		ads_camera.global_position = lerp(ads_camera.global_position, ads_pivot.global_position, .2)
		SPEED = 2.0
	else:
		crosshair.show()
		ads_camera.global_position = lerp(ads_camera.global_position, camera_3d.global_position, .2)
		if ads_camera.global_position.is_equal_approx(camera_3d.global_position):
			camera_3d.current = true
			camera_pivot.current_camera = camera_3d
		SPEED = 5.0
		
	var input_dir
	if OS.get_name() == "Android":
		if joystick.has_method("get_direction"):
			input_dir = joystick.get_direction()
	else:
		input_dir = Input.get_vector("left", "right", "up", "down")
		if Input.is_action_just_pressed("fire"):
			if !Manager.CURSOR_MODE_ENABLED:
				if has_gun():
					get_current_gun().fire_bullet()
			
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
		self.rotation.y = event.relative.x/1000*Manager.CAMERA_SENSITIVITY


func set_platform_configurations():
	if OS.get_name() == "Android":
		joystick.show()
		camera_drag.show()
		jump_btn.show()
		fire_btn.show()
		ads_btn.show()
	else:
		joystick.hide()
		camera_drag.hide()
		jump_btn.hide()
		fire_btn.hide()
		ads_btn.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		Manager.CURSOR_MODE_ENABLED = false


func _input(event):
	if OS.get_name() == "Windows":
		if !Manager.CURSOR_MODE_ENABLED:
			if event is InputEventMouseMotion:
				self.rotation.y -= event.relative.x/1000*Manager.CAMERA_SENSITIVITY


func _on_jump_pressed():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY


func _on_fire_pressed():
	if has_gun():
		get_current_gun().fire_bullet()

func toggle_ads():
	if has_gun():
		enable_ads = !enable_ads
	


func _on_ads_pressed():
	toggle_ads()

func drop_gun():
	if has_gun():
		var current_gun = get_current_gun()
		var gun : Node3D = current_gun.duplicate()
		var temp_objects = get_tree().get_first_node_in_group("temp_objects")
		gun.global_position = foot.global_position
		temp_objects.add_child(gun)
		gun.rotation_degrees.z = 90
		current_gun.queue_free()
		weapons.remove_gun()
		gun.dropped = true
	if enable_ads:
		enable_ads = false
	

func pick_object(obj_id):
	var obj = get_obj_by_id(obj_id)
	var new = obj.duplicate()
	
	if weapons.has_two_guns():
		drop_gun()
	else:
		if has_gun():
			add_secondary_weapon(obj_id)
			return
			
	gun_pivot.add_child(new)
	obj.queue_free()
	new.dropped = false
	new.rotation_degrees = Vector3.ZERO
	var t = get_tree().create_tween()
	t.tween_property(new, "position", Vector3.ZERO, .2).set_ease(Tween.EASE_OUT)
	t.play()
	weapons.add_gun(new.head, new)

func add_secondary_weapon(obj_id):
	var obj = get_obj_by_id(obj_id)
	var new = obj.duplicate()
	secondary_gun_pivot.add_child(new)
	new.position = Vector3.ZERO
	obj.queue_free()
	new.dropped = false
	new.rotation_degrees.x = 90
	new.rotation_degrees.y = -90
	new.rotation_degrees.z = 0
	weapons.add_gun(new.head, new)
	select_gun(new)
	
func select_gun(gun):
	
	var dup = gun.duplicate()
	if !has_gun():
		gun_pivot.add_child(dup)
		gun.queue_free()
		dup.dropped = false
		dup.position = Vector3.ZERO
		dup.rotation_degrees = Vector3.ZERO
	else:
		if gun != get_current_gun():
			var pri = get_current_gun()
			var sec = get_secondary_gun()
			
			var pri_dup = pri.duplicate()
			var sec_dup = sec.duplicate()
			sec_dup.dropped = false
			pri_dup.dropped = false
			weapons.get_current_selected_weapon().get_parent().gun = sec_dup
			weapons.get_secondary_slot().get_parent().gun = pri_dup
			pri.queue_free()
			sec.queue_free()
			
			secondary_gun_pivot.add_child(pri_dup)
			gun_pivot.add_child(sec_dup)
			
			var temp_rot = pri_dup.rotation_degrees
			var temp_pos = pri_dup.position
			pri_dup.position = sec_dup.position
			pri_dup.rotation_degrees = sec_dup.rotation_degrees
			sec_dup.position = temp_pos
			sec_dup.rotation_degrees = temp_rot
	
		
	
func has_gun():
	return gun_pivot.get_child_count() > 0

func get_current_gun():
	return gun_pivot.get_child(0)

func get_secondary_gun():
	return secondary_gun_pivot.get_child(0)
	
func show_pickable(texture: Texture2D, head: String, description: String, object):
	near_objects[texture.resource_path] = object
	pickable_list.add_pickable(texture, head, description)

func hide_pickable(texture: String, object):
	near_objects.erase(texture)
	pickable_list.remove_pickable(texture)
