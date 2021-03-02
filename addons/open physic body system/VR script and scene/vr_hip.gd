extends "../base script/hip_base.gd"

export var arvr_origin_p : NodePath
onready var arvr_origin : Spatial = get_node(arvr_origin_p)
onready var left_controller : Spatial = arvr_origin.get_node("left_controller")
onready var right_controller : Spatial = arvr_origin.get_node("right_controller")
onready var hmd : Spatial = arvr_origin.get_node("hmd")

enum MovementOrientation { HEAD, HAND_LEFT, HAND_RIGHT }
export(MovementOrientation) var movement_orientation := MovementOrientation.HEAD
enum LocomotionStickTurnType {CLICK , SMOOTH}
export(LocomotionStickTurnType) var turn_type = LocomotionStickTurnType.CLICK

export var vertical_speed : float = 3


var last_click_rotate = false
export var dead_zone = 0.125
var dead_zone_epsilon = 0.8
export var smooth_turn_speed := 90.0;
export var click_turn_angle := 45.0; 

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
	if target_height > max_height:
			height_offset -= delta* 10
	elif target_height < min_height:
			height_offset += delta* 10
	
	
	var view_dir: Vector3
	var strafe_dir: Vector3
	var dir : Vector3
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
		
	if left_controller.axis[1] > 0.5 :
			dir +=  view_dir
	elif left_controller.axis[1] < -0.5 :
			dir +=  - view_dir

	if left_controller.axis[0] < -0.5 :
			dir += - strafe_dir
	elif left_controller.axis[0] > 0.5 :
			dir += strafe_dir
	
		
	dir = -dir.normalized()
#		vel = dir * speed * delta
	if right_controller.axis[1] < -0.5 :
#			target_height -= 1 * delta * vertical_speed
			height_offset -= 1 * delta * vertical_speed
	elif right_controller.axis[1] > 0.5 :
#			target_height += 1 * delta * vertical_speed
			height_offset += 1 * delta * vertical_speed
		
#		movement through the base hip script
	max_height = hmd.global_transform.origin.y 
	target_height = hmd.global_transform.origin.y + height_offset - global_transform.origin.y
	move_direction = dir
		
		
func turn(dt):
	#function from the oculus quest toolkit with a few replacement due to a different structure
	var dlr = -right_controller.axis[0]

	if (last_click_rotate): # reset to false only when stick is moved in deadzone; but with epsilon
		last_click_rotate = (abs(dlr) > dead_zone * dead_zone_epsilon); 

	if (abs(dlr) <= dead_zone): 
		return;

	var origHeadPos = hmd.global_transform.origin;
	
	# click turning
	if (turn_type == LocomotionStickTurnType.CLICK && !last_click_rotate):
		last_click_rotate = true;
		var dsign = sign(dlr);
		arvr_origin.rotate_y(dsign * deg2rad(click_turn_angle));
			
	# smooth turning
	elif (turn_type == LocomotionStickTurnType.SMOOTH):
#		if (enable_vignette) : movement_vignette_rect.visible = true;
		arvr_origin.rotate_y(deg2rad(dlr * smooth_turn_speed * dt));

	# reposition vrOrigin for in place rotation
	arvr_origin.global_transform.origin +=  origHeadPos - hmd.global_transform.origin;
	arvr_origin.global_transform = hmd.global_transform.orthonormalized();
