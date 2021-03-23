extends RigidBody
#"base of both feet and hand of the vr character an AI physic character or a flatscreen player 
#"the hands, the stabilizing spehere and the head have an extends script that follow the controller"
#"for the feet they are instructed by the hip script"

# determine the body (node a of the joint)
export var body_p : NodePath 
onready var body : RigidBody = get_node(body_p)

#if true the rigisdbody will set its joint to stay at the same local position as set in the editor
export var is_stable : bool = false

var is_grabbing := false
var grabbed_obj : Node 
var grab_joint :Node

# coords and basis for the joint and PID controller to target
export var target_pos := Vector3.ZERO
export var target_basis : Basis

#reffer to the 6DOFJoint that allows the rigidbody to move
onready var pos_joint : Generic6DOFJoint 

#to enable the rotation
export var is_stabilizing_rotation : bool = true
export var is_targeting_basis : bool = true

#(PID is a Vector 3 X = Proportionnal, Y = Integral and Z = Differential)
# the variable for the PID setting it to no angular momentum
export var PID_to_zero := Vector3(2,0,0) 
var last_error_z := Vector3.ZERO
var integral_z   := Vector3.ZERO

# the variable for the 2 axis of rotation : pitch and yaw
export var PID_to_target := Vector3(50,0,0.1)
var last_error_t := Vector3.ZERO
var integral_t   := Vector3.ZERO

# the variable for the roll axis of rotation
export var PID_to_roll := Vector3(15,0,0.01)
var last_error_r := Vector3.ZERO
var integral_r   := Vector3.ZERO

# set the maximum lenght the joint can push, usefull if you don't want to have a limit for exemple of arm lenght
export var max_length := Vector3.INF
# determine if the joint as a max lenght the extremities can be pulled to
#for exemple you could have an hand that cannot be targetted farther than 1 meter away, but could be pulled away from it limit, creating a slingshot effect
export var is_an_hard_limit : bool = false

# joint force (stiffness) and damping, note that the damping is what smooths out the impulse, thus reducing the pendulum effect
export var stiffness := 100
export var damping := 5

#if you want to have offset from the instructed posistion, 
#due note that the offset between the node a and node b is added to insure that the local pos correspond with the actual local pos
export var manual_offset := Vector3.ZERO
var offset  := Vector3.ZERO

var offset_from_grabbed_obj

func _ready():
	print(self.get_name())
	create_new_pos_joint(self)
	
	
	
		
	

func grab():
#	 add the function of grabbing to allow for both hand and feet grabbing with a single script insuring consistant behavior between the two
	if get_colliding_bodies().size() > 1:
#		add priority
		print("too many body")
	elif get_colliding_bodies().size() > 0:
		var obj = get_colliding_bodies()[0]
		grab_obj(obj)
#		

		
#		grab_obj.append(obj)
		
func grab_obj(obj_to_grab):
		print(obj_to_grab.get_name())
		if obj_to_grab is StaticBody || obj_to_grab is KinematicBody:
#			if the object is static and we want a perfect grab, we make the rigidbody go static as to not have offset when push and pulled around
			mode = MODE_KINEMATIC
			offset_from_grabbed_obj = obj_to_grab.global_transform.origin - self.global_transform.origin
#			print("static grabbing")
		else:
#			create_new_pos_joint(obj_to_grab)
			offset_from_grabbed_obj = obj_to_grab.global_transform.origin - self.global_transform.origin
			print(get_node(pos_joint.get_node_b()).get_name())
			mode = MODE_KINEMATIC
			
			
#			joint created to make the hand doesn't collide with the grabbed object
			var joint := Generic6DOFJoint.new()
			self.add_child(joint)
			joint.global_transform = global_transform
			joint.set_node_a(self.get_path())
			joint.set_node_b(obj_to_grab.get_path())
			joint.set("linear_limit_x/enabled",false)
			joint.set("linear_limit_y/enabled",false)
			joint.set("linear_limit_z/enabled",false)
			joint.set("angular_limit_x/enabled",false)
			joint.set("angular_limit_y/enabled",false)
			joint.set("angular_limit_z/enabled",false)
			grab_joint = joint
			
		
#			print("joint grabbing")
		is_grabbing = true
		grabbed_obj = obj_to_grab

func drop():
	if grab_joint != null:
		get_node(pos_joint.get_node_b()).queue_free()
		grab_joint = null
		
	if grabbed_obj != null:
		grabbed_obj.queue_free()
		grabbed_obj = null
	if mode == MODE_KINEMATIC:
#		global_transform.origin = body.global_transform.origin + target_pos + offset
		mode = MODE_RIGID
		sleeping = false
	if pos_joint != null && has_method("grip_start") && is_grabbing:
#		create_new_pos_joint(self)
		pass
	is_grabbing = false
	
func create_new_pos_joint(new_node_b):
		var new_joint = Generic6DOFJoint.new()
		
#		enable the linear spring as it is the way we move the position of the hand relative to the body
		new_joint.set("linear_spring_x/enabled",true)
		new_joint.set("linear_spring_y/enabled",true)
		new_joint.set("linear_spring_z/enabled",true)
		
#		disable angular limit so that the pid can handle the rotation
		new_joint.set("angular_limit_x/enabled",false)
		new_joint.set("angular_limit_y/enabled",false)
		new_joint.set("angular_limit_z/enabled",false)
		
#		disable the linear_limit if no max_lenght is set,
#		note that if you are using a max_lenght you are not forced to have a joint linear limit
#		thus you could have an hand that cannot be targetted farther than 1 meter away, but could be pulled away from it limit, creating a slingshot effect
		
		new_joint.set("linear_limit_x/enabled",false)
		new_joint.set("linear_limit_y/enabled",false)
		new_joint.set("linear_limit_z/enabled",false)
#		if is_an_hard_limit && max_length.length() > INF:
#			new_joint.set("linear_limit_x/enabled",true)
#			new_joint.set("linear_limit_y/enabled",true)
#			new_joint.set("linear_limit_z/enabled",true)
			
#			 will need to add the linear limit value here to make hard limit work
		
		new_joint.set("linear_spring_x/stiffness",stiffness)
		new_joint.set("linear_spring_y/stiffness",stiffness)
		new_joint.set("linear_spring_z/stiffness",stiffness)

		new_joint.set("linear_spring_x/damping",damping)
		new_joint.set("linear_spring_y/damping",damping)
		new_joint.set("linear_spring_z/damping",damping)
		
		new_joint.set_node_a(get_path_to(body))
		new_joint.set_node_b(get_path_to(new_node_b))
		
		
#		the offset between the node a(body) and node b(self or grabbed object) is added to insure that the local pos correspond with the actual local pos
		offset = body.global_transform.origin - self.global_transform.origin + manual_offset
#		if pos_joint != null:
#			pos_joint.queue_free()
		pos_joint = new_joint
		new_joint.transform = self.transform
		add_child(new_joint)
#		
		


	
func _physics_process(delta):
			#position
			if mode == MODE_KINEMATIC:
#				global_transform.origin = grabbed_obj.global_transform.origin - offset_from_grabbed_obj
				global_transform.basis = target_basis
			if !is_stable:
				target_pos += offset
			
			
			if pos_joint != null:
				pos_joint.set("linear_spring_x/equilibrium_point", clamp(target_pos.x,-max_length.x, max_length.x))
				pos_joint.set("linear_spring_y/equilibrium_point", clamp(target_pos.y,-max_length.y, max_length.y))
				pos_joint.set("linear_spring_z/equilibrium_point", clamp(target_pos.z,-max_length.z, max_length.z))
			
#			print(target_pos)
			#rotation
			var node_to_rot = self
			if is_grabbing:
				node_to_rot  = grabbed_obj
			if node_to_rot.has_method("add_torque"):
				if is_stabilizing_rotation:
					#restore angular velocity to 0
					var correction_to_zero = PID(-angular_velocity,delta,0)
					node_to_rot.add_torque(correction_to_zero)
					#rotation
				if is_targeting_basis:
					var error_target :Vector3 = - target_basis.z.cross(transform.basis.z)
					var correction_to_target = PID(error_target,delta,1)
					node_to_rot.add_torque(correction_to_target)
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
					node_to_rot.add_torque(PID(error_roll,delta,2))



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

