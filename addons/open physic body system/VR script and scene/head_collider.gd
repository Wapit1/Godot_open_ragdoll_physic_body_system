extends "res://addons/open physic body system/base script/phys_extremities.gd"

var stabilised_target : Vector3

func _ready():
	stabilised_target = global_transform.origin


func _physics_process(delta):
	linear_velocity = Vector3.ZERO
	target_pos = stabilised_target - body.global_transform.origin
