extends RigidBody
#"base of both feet and hand of the vr character 
#(and potentially both hands and feet of an AI physic oppenent or a flatscreen player) "
#"the hands have an extends script that follow the controller"
#"for the feet they are instructed by the body script"
export var body_p : NodePath 
onready var body : RigidBody = get_node(body_p)

var is_grabbing := false
var grab_obj := []
var grab_joint := []

export var target_pos := Vector3.ZERO
export var target_basis : Basis

onready var pos_joint : Generic6DOFJoint = get_node("Generic6DOFJoint")

export var PID_to_zero := Vector3(2,0,0) 
var last_error_z := Vector3.ZERO
var integral_z   := Vector3.ZERO

export var PID_to_target := Vector3(50,0,0.1)
var last_error_t := Vector3.ZERO
var integral_t   := Vector3.ZERO

export var PID_to_roll := Vector3(15,0,0.01)
var last_error_r := Vector3.ZERO
var integral_r   := Vector3.ZERO

export var max_length := Vector3.INF

export var stiffness := 100
export var damping := 5


export var offset : Vector3 = Vector3(0,-1,0)

func _ready():
	if pos_joint != null:
		pos_joint.set("linear_spring_x/stiffness",stiffness)
		pos_joint.set("linear_spring_y/stiffness",stiffness)
		pos_joint.set("linear_spring_z/stiffness",stiffness)

		pos_joint.set("linear_spring_x/damping",damping)
		pos_joint.set("linear_spring_y/damping",damping)
		pos_joint.set("linear_spring_z/damping",damping)
		
		
		offset = body.global_transform.origin - self.global_transform.origin

	else:
		print("pos_joint is null ")

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
		is_grabbing = true
		
#		grab_obj.append(obj)

		print("grabbing")

func drop():
	if mode == MODE_KINEMATIC:
		mode = MODE_RIGID
	
	for j in grab_joint:
		j.queue_free()
		grab_joint.erase(j)
	is_grabbing = false

func _physics_process(delta):
			#position
			target_pos += offset
			pos_joint.set("linear_spring_x/equilibrium_point", clamp(target_pos.x,-max_length.x, max_length.x))
			pos_joint.set("linear_spring_y/equilibrium_point", clamp(target_pos.y,-max_length.y, max_length.y))
			pos_joint.set("linear_spring_z/equilibrium_point", clamp(target_pos.z,-max_length.z, max_length.z))
			
#			print(target_pos)
			#rotation
			
			#restore angular velocity to 0
			var correction_to_zero = PID(-angular_velocity,delta,0)
			add_torque(correction_to_zero)
			#rotation
			var error_target :Vector3 = - target_basis.z.cross(transform.basis.z)
			var correction_to_target = PID(error_target,delta,1)
			add_torque(correction_to_target)
			#roll
			var error_roll : Vector3 
			var cross_p_roll :Vector3 = target_basis.x.cross(transform.basis.x)
			if target_basis.x.x > 0 && target_basis.y.y > 0 || target_basis.z.z > 0:
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

