extends Node3D

@onready var muzzle_flash = $MuzzleFlash
@onready var animation_player = $AnimationPlayer
@onready var shot_marker = $ShotMarker

const DELAY = .4
var fire_time: float

const BULLET = preload("res://Prefabs/bullet.tscn")

var camera_pivot
var temp_objects

var dropped: bool = true

@export var icon: Texture2D
@export var head: String
@export var description: String

func _physics_process(delta):
	fire_time += delta
	
	
func _ready():
	if get_tree().has_group("camera_pivot"):
		camera_pivot = get_tree().get_nodes_in_group("camera_pivot")[0]
	if get_tree().has_group("temp_objects"):
		temp_objects = get_tree().get_nodes_in_group("temp_objects")[0]
		
func fire_bullet():
	if fire_time >= DELAY:
		muzzle_flash.emitting = true
		animation_player.play("fire_anim")
		var bullet = BULLET.instantiate()
		temp_objects.add_child(bullet)
		bullet.global_position = shot_marker.global_position
		bullet.look_at(camera_pivot.get_target_position())
		bullet.direction = bullet.global_position.direction_to(camera_pivot.get_target_position())
		fire_time = 0
	


func _on_player_detector_body_entered(body):
	if body.is_in_group("player") && dropped:
		body.show_pickable(icon, head, description)


func _on_player_detector_body_exited(body):
	if body.is_in_group("player") && dropped:
		body.hide_pickable(icon.resource_path)
