extends "res://addons/open physic body system/base script/phys_extremities.gd"

export var offset_pos := Vector3.ZERO
export var hmd_p : NodePath
onready var hmd :Spatial= get_node(hmd_p)

func _physics_process(delta):
	target_pos = (hmd.global_transform.origin - body.global_transform.origin) - offset_pos
	
