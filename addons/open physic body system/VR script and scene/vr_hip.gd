extends "../base script/hip_base.gd"

export var arvr_origin_p : NodePath
onready var arvr_origin : Spatial = get_node(arvr_origin_p)
onready var left_controller : Spatial = arvr_origin.get_node("left_controller")
onready var right_controller : Spatial = arvr_origin.get_node("right_controller")
onready var hmd : Spatial = arvr_origin.get_node("hmd")

enum MovementOrientation { HEAD, HAND_LEFT, HAND_RIGHT }
export(MovementOrientation) var movement_orientation := MovementOrientation.HEAD

export var vertical_speed : float = 3


# radian angle to concider the hmd as angled
export var angle_for_angled_hmd : float = 0.5
export var max_range_from_flat_hmd : float = 3
export var max_range_from_angled_hmd : float = 6
var is_catching_up_to_hmd : bool = false
var catching_up_move := Vector3.ZERO 
var last_valid_hmd_height : float = 0


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
#	separation as a function, both for cleanliness (as it could get bloated later on) 
#and for using an as_method on other node to deferentiate hip_base from VR_hip
	hmd_catching_up_to()
	
	
	if target_height > max_height:
			height_offset -= delta* 10
	elif target_height < min_height:
			height_offset += delta* 10
	
	
	var view_dir: Vector3
	var strafe_dir: Vector3
	
	match movement_orientation:
		MovementOrientation.HAND_RIGHT:
			view_dir = -right_controller.global_transform.basis.z;
			strafe_dir = right_controller.global_transform.basis.x;
		MovementOrientation.HAND_LEFT:
			view_dir = -left_controller.global_transform.basis.z;
			strafe_dir = left_controller.global_transform.basis.x;
		MovementOrientation.HEAD, _:
			view_dir = -hmd.global_transform.basis.z;
			strafe_dir = hmd.global_transform.basis.x;
	
	view_dir.y = 0.0;
	strafe_dir.y = 0.0;
	view_dir = view_dir.normalized();
	strafe_dir = strafe_dir.normalized();
		
	input_direction = Vector3.ZERO
	if left_controller.axis[1] > 0.5 :
			input_direction +=  view_dir
	elif left_controller.axis[1] < -0.5 :
			input_direction +=  - view_dir

	if left_controller.axis[0] < -0.5 :
			input_direction += - strafe_dir
	elif left_controller.axis[0] > 0.5 :
			input_direction += strafe_dir
	
		
	input_direction = -input_direction.normalized()
#		vel = input_direction * speed * delta
	if right_controller.axis[1] < -0.5 :
			height_offset -= 1 * delta * vertical_speed
	elif right_controller.axis[1] > 0.5 :
			height_offset += 1 * delta * vertical_speed
			
	last_valid_hmd_height = (hmd.global_transform.origin - global_transform.origin).y 
#		movement through the base hip script
	max_height = hmd.global_transform.origin.y 
	target_height = last_valid_hmd_height + height_offset 
	move_direction = (input_direction + catching_up_move)
#	print(move_direction)
	
	
func hmd_catching_up_to():
		var hmd_local_pos = hmd.global_transform.origin - global_transform.origin
#	if hmd.global_transform.basis.y.cross(Vector3.UP).length() > angle_for_angled_hmd:
#		if Vector2(hmd_local_pos.x,hmd_local_pos.z).length() > max_range_from_angled_hmd:
#			 catching_up_move = - Vector3(hmd_local_pos.x,0,hmd_local_pos.z).normalized()
#		else:
#			catching_up_move = Vector3.ZERO
#
#	else:
		if Vector2(hmd_local_pos.x,hmd_local_pos.z).length() > max_range_from_flat_hmd:
			catching_up_move = - Vector3(hmd_local_pos.x,0,hmd_local_pos.z).normalized()
		else:
			catching_up_move = Vector3.ZERO
			last_valid_hmd_height = hmd_local_pos.y
		if catching_up_move.length() > 0:
			is_catching_up_to_hmd = true
#			print("catching up move:" + String(catching_up_move) +"hmd local pos :"+ String(hmd_local_pos))
		else:
			catching_up_move = Vector3.ZERO #repetition
			is_catching_up_to_hmd = false
	
	

		
