extends "../base script/hip_base.gd"

export var arvr_origin_p : NodePath
onready var arvr_origin : Spatial = get_node(arvr_origin_p)
onready var left_controller : Spatial = arvr_origin.get_node("left_controller")
onready var right_controller : Spatial = arvr_origin.get_node("right_controller")
onready var hmd : Spatial = arvr_origin.get_node("hmd")

export var vertical_speed : float = 5

# for when the body will follow the player
#var height_offset


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
			dir += - cam_xform.basis.z 
		elif left_controller.axis[1] < -0.5 :
			dir += cam_xform.basis.z 

		if left_controller.axis[0] < -0.5 :
			dir += - cam_xform.basis.x 
		elif left_controller.axis[0] > 0.5 :
			dir += cam_xform.basis.x 

		dir = dir.normalized()
#		vel = dir * speed * delta
		if right_controller.axis[1] < -0.5 :
			target_height += 1 * delta * vertical_speed
#			height_offset += -1 * delta * vertical_speed
		elif right_controller.axis[1] > 0.5 :
			target_height -= 1 * delta * vertical_speed
#			height_offset += 1 * delta * vertical_speed


		move_direction = dir
		
