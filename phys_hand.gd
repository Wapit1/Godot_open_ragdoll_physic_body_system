extends RigidBody


export var controller_p : NodePath
onready var controller : = get_node(controller_p)

var grab_obj := []
var grab_joint := []

var target_rot := Vector3.ZERO

export var PID_to_zero := Vector3(2,0,0) 
var last_error_z := Vector3.ZERO
var integral_z   := Vector3.ZERO

export var PID_to_target := Vector3(50,0,0.1)
var last_error_t := Vector3.ZERO
var integral_t   := Vector3.ZERO

export var PID_to_roll := Vector3(15,0,0.01)
var last_error_r := Vector3.ZERO
var integral_r   := Vector3.ZERO


var is_targetting := true

func _ready():
#	controller.connect("trigger_start",self,"trigger_start")
##	controller.connect("trigger_while",self,"trigger_while")
#	controller.connect("trigger_end",self,"trigger_end")

	controller.connect("grip_start",self,"grip_start")
#	controller.connect("grip_while",self,"grip_while")
	controller.connect("grip_end",self,"grip_end")
#
#	controller.connect("farb_start",self,"farb_start")
#	controller.connect("farb_end",self,"farb_end")
#
#	controller.connect("farb_start",self,"farb_start")
#	controller.connect("farb_end",self,"farb_end")
#
#	controller.connect("clob_start",self,"clob_start")
#	controller.connect("clob_end",self,"clob_end")
#
#	controller.connect("axis_press_start",self,"axis_press_start")
#	controller.connect("axis_press_end",self,"axis_press_end")

func grip_start():
	print("input received")
	grab()

func grab():
	if get_colliding_bodies().size() > 1:
		print("too many body")
	elif get_colliding_bodies().size() > 0:
		var obj = get_colliding_bodies()[0]
		if obj is StaticBody:
			mode = MODE_KINEMATIC
		else:
			var joint := Generic6DOFJoint.new()
			self.add_child(joint)
			joint.global_transform = global_transform
			joint.set_node_a(self.get_path())
			joint.set_node_b(obj.get_path())
			grab_joint.append(joint)
		
		
#		grab_obj.append(obj)

		print("grabbing")

func grip_end():
	drop()

func drop():
	if mode == MODE_KINEMATIC:
		mode = MODE_RIGID
	
	for j in grab_joint:
		j.queue_free()
		grab_joint.erase(j)

func _physics_process(delta):

	
			var correction_to_zero = PID(-angular_velocity,delta,0)
			add_torque(correction_to_zero)


			var target_basis = controller.global_transform.basis
			var error_target :Vector3 = - target_basis.z.cross(transform.basis.z)
			var correction_to_target = PID(error_target,delta,1)
			add_torque(correction_to_target)


	#		
			var error_roll : Vector3 
			var cross_p_roll :Vector3 = target_basis.x.cross(transform.basis.x)
			if target_basis.x.x > 0 && target_basis.y.y > 0 || target_basis.z.z > 0:
	#		if true:
				if cross_p_roll.z >= 0 :
					error_roll = transform.basis.z * - cross_p_roll.length()
				else:
					error_roll = transform.basis.z *  cross_p_roll.length()
			else:
				if cross_p_roll.z >= 0 :
					error_roll = transform.basis.z * cross_p_roll.length()
				else:
					error_roll = transform.basis.z * - cross_p_roll.length()


			add_torque(PID(error_roll,delta,2))

#	get_node("hand_joint").update_pos()

func PID(current_error:Vector3,time:float,PID_num:int):

	if PID_num == 0:
		integral_z += current_error * time
		var deriv = (current_error - last_error_z) /time
		last_error_z = current_error
		return current_error*PID_to_zero.x + integral_z *PID_to_zero.y + deriv*PID_to_zero.z
	elif PID_num == 1:
		integral_t += current_error * time
		var deriv = (current_error - last_error_t) /time
		last_error_t = current_error
		return current_error*PID_to_target.x + integral_t *PID_to_target.y + deriv*PID_to_target.z
	else:
		integral_r += current_error * time
		var deriv = (current_error - last_error_r) /time
		last_error_r = current_error
#		if deriv.length() > 15:
#			print(rotation_degrees)
		return current_error*PID_to_roll.x + integral_t *PID_to_roll.y + deriv*PID_to_roll.z
#

