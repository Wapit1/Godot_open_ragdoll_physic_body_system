extends "phys_body_vr_player.gd"

export var test : int

func _physics_process(delta):
	var velocity := Vector3.ZERO
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
	if Input.is_action_pressed('ui_down'):
		velocity.z += 1
	if Input.is_action_pressed('ui_up'):
		velocity.z -= 1
	move_direction = velocity.normalized()
