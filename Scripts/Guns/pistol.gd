extends Node3D

@onready var muzzle_flash = $MuzzleFlash
@onready var animation_player = $AnimationPlayer
@onready var shot_marker = $ShotMarker

const BULLET = preload("res://Prefabs/bullet.tscn")

var camera_pivot
var temp_objects

func _ready():
	if get_tree().has_group("camera_pivot"):
		camera_pivot = get_tree().get_nodes_in_group("camera_pivot")[0]
	if get_tree().has_group("temp_objects"):
		temp_objects = get_tree().get_nodes_in_group("temp_objects")[0]
		
func fire_bullet():
	muzzle_flash.emitting = true
	animation_player.play("fire_anim")
	var bullet = BULLET.instantiate()
	temp_objects.add_child(bullet)
	bullet.global_position = shot_marker.global_position
	bullet.look_at(camera_pivot.get_target_position())
	bullet.direction = bullet.global_position.direction_to(camera_pivot.get_target_position())
	
