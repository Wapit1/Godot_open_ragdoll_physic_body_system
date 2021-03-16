extends "../base script/hip_base.gd"

#export var test : int = 0

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
	
	if Input.is_action_pressed("ui_select"):
		if target_height > min_height:
			target_height -= delta* 10
	elif Input.is_action_just_released("ui_select"):
		target_height = 20
		drop_all()
