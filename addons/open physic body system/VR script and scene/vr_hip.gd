extends "../base script/hip_base.gd"

export var arvr_origin_p : NodePath
onready var arvr_origin : Spatial = get_node(arvr_origin_p)
onready var left_controller : Spatial = arvr_origin.get_node("left_controller")
onready var right_controller : Spatial = arvr_origin.get_node("right_controller")
onready var hmd : Spatial = arvr_origin.get_node("hmd")

export var vertical_speed : float = 3

export var stabilizing_sphere_p : NodePath
onready var stabilizing_sphere :Spatial = get_node(stabilizing_sphere_p)


var snap_turn_dir : int = 0

func _ready():
	
#	target_height
#	skeleton.physical_bones_start_simulation(["LeftArm","RightArm","LeftUpLeg","RightUpLeg"])
	
	var VR = ARVRServer.find_interface('OpenVR')
	if VR && VR.initialize():
		get_viewport().arvr = true
		get_viewport().hdr = false
		OS.vsync_enabled = false
		Engine.target_fps = 72
	else:
		print('no interface')
#	right_controller.connect("farb_start",self,"change_followbody")

func _physics_process(delta):
#		locomotion
		var dir := Vector3.ZERO
		var cam_xform = hmd.get_global_transform()

		if left_controller.axis[1] > 0.5 :
			dir +=  Vector3.FORWARD
		elif left_controller.axis[1] < -0.5 :
			dir +=  - Vector3.FORWARD

		if left_controller.axis[0] < -0.5 :
			dir += - Vector3.RIGHT
		elif left_controller.axis[0] > 0.5 :
			dir += Vector3.RIGHT
		
		
		
		dir = dir.normalized()
#		vel = dir * speed * delta
		if right_controller.axis[1] < -0.5 :
#			target_height -= 1 * delta * vertical_speed
			height_offset -= 1 * delta * vertical_speed
		elif right_controller.axis[1] > 0.5 :
#			target_height += 1 * delta * vertical_speed
			height_offset += 1 * delta * vertical_speed
		
#		movement through the base hip script
		target_height = hmd.global_transform.origin.y + height_offset - global_transform.origin.y
		move_direction = dir
		
		stabilizing_sphere.target_pos = Vector3(0,-target_height,0)
		if move_direction.length() > 0:
			stabilizing_sphere.is_stabilizing_rotation = false
		else:
#			for bracking
			stabilizing_sphere.is_stabilizing_rotation = true
		
		
#		snap turning
		if round(right_controller.axis[0]) != 0 :
			if right_controller.axis[0] > -0.75 && snap_turn_dir != 1 :
				rotate_y(-TAU/8)
				snap_turn_dir = 1
			elif right_controller.axis[0] < 0.75 && snap_turn_dir != 2:
				rotate_y(TAU/8)
				snap_turn_dir = 2
		else:
			snap_turn_dir = 0
