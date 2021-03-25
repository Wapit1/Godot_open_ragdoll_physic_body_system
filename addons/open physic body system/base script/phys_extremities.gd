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
onready var pos_joint : Generic6DOFJoint = get_node("Generic6DOFJoint")

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
var original_offset := Vector3.ZERO

var offset_from_grabbed_obj := Vector3.ZERO
var kin_follow_node : Spatial
var can_grab_array := []

var original_collision_layer : int
var original_collision_mask : int

func _ready():
	if body == null:
		body = get_node(pos_joint.get_node_a())
	configure_pos_joint()
	#the offset between the node a(body) and node b(self) is added to insure that the local pos correspond with the actual local pos
	offset = body.global_transform.origin - self.global_transform.origin + manual_offset
	original_offset = offset
	
func configure_pos_joint():

	if pos_joint != null:
		
		pos_joint.set("linear_spring_x/enabled",true)
		
		pos_joint.set("linear_spring_y/enabled",true)
		
		pos_joint.set("linear_spring_z/enabled",true)
		
		pos_joint.set("linear_spring_x/stiffness",stiffness)
		pos_joint.set("linear_spring_y/stiffness",stiffness)
		pos_joint.set("linear_spring_z/stiffness",stiffness)

		pos_joint.set("linear_spring_x/damping",damping)
		pos_joint.set("linear_spring_y/damping",damping)
		pos_joint.set("linear_spring_z/damping",damping)
		

		

		pos_joint.set("linear_limit_x/enabled",false)
		pos_joint.set("linear_limit_y/enabled",false)
		pos_joint.set("linear_limit_z/enabled",false)
		
		# determine if the joint as a max lenght the extremities can be pulled to
		#for exemple you could have an hand that cannot be targetted farther than 1 meter away, but could be pulled away from it limit, creating a slingshot effect
		if is_an_hard_limit && max_length.length() > INF:
			pos_joint.set("linear_limit_x/enabled",true)
			pos_joint.set("linear_limit_y/enabled",true)
			pos_joint.set("linear_limit_z/enabled",true)
			
			
		
	else:
		print("pos_joint is null for" + self.get_name())

func grab():
	
#	 add the function of grabbing to allow for both hand and feet grabbing with a single script insuring consistant behavior between the two
	var obj_to_grab : Spatial
	var grabbable_array = []
	
	for node in can_grab_array :
		if node is Area:
			if node.hand_pose.size() <= node.number_of_hand_grabbing:
				return
		grabbable_array.append(node)
		
	for node in get_colliding_bodies():
		grabbable_array.append(node)
	print( "grabbable array of " + self.get_name() + " :" + String(grabbable_array))
	if grabbable_array.size() > 1:
		var current_priority : float
		var highest_priority : float = -100
		var approved_node := []
		for node in grabbable_array:
			current_priority = 0
			if node == self:
				print("something is wrong " + self.get_name() + " is trying to grab itself")
			elif node.is_in_group("grab_point"):
				current_priority = node.grabbing_priority
			if node is RigidBody:
				if self.is_in_group("hand"):
					current_priority = 1
				else:
					current_priority = -1
			if current_priority  > highest_priority:
				highest_priority = current_priority
				approved_node.clear()
				approved_node.append(node)
			elif current_priority == highest_priority:
				approved_node.append(node)
#			useless
#			elif highest_priority <= 0:
#				highest_priority = 0
#				approved_node.append(self)
		if approved_node.size() > 1:
			var closest_distance : float = 1000
			var closest_node : Spatial
			for node in approved_node:
				if (node.global_transform.origin - global_transform.origin).length() < closest_distance:
					closest_distance = (node.global_transform.origin - global_transform.origin).length()
					closest_node = self
			obj_to_grab = closest_node
		else:
			obj_to_grab = approved_node[0]
		grab_obj(obj_to_grab)
		
	elif grabbable_array.size() == 1 && grabbable_array[0] != self:
		var obj = grabbable_array[0]
		grab_obj(obj)
#		

		
#		grab_obj.append(obj)
		
func grab_obj(obj_to_grab):
	
	if obj_to_grab.get_parent() == self.get_parent():
		print(self.get_name() + " tried to grab a body part of its body")
		return
	
	print(self.get_name() + " is grabbing " + obj_to_grab.get_name() + "(" + String(obj_to_grab.get_instance_id()) + ")")

	pos_joint.global_transform.basis = body.global_transform.basis
	
	offset = body.global_transform.origin - self.global_transform.origin + manual_offset
	
	mode = MODE_KINEMATIC
	original_collision_layer = collision_layer 
	original_collision_mask = collision_mask
	collision_layer = 0
	collision_mask = 0
#	 Follow node is created when there is no grab point
	if obj_to_grab.is_in_group("grab_point"):
		pos_joint.set_node_b("../" +get_path_to(obj_to_grab.get_parent()))
		kin_follow_node = obj_to_grab
		
		offset_from_grabbed_obj = obj_to_grab.hand_position
		obj_to_grab.add_hand(self)
	
	else:
		pos_joint.set_node_b("../" +get_path_to(obj_to_grab))
		
		var new_follow_node = Position3D.new()
		obj_to_grab.add_child(new_follow_node)
		new_follow_node.global_transform.origin = self.global_transform.origin 
		new_follow_node.global_transform.basis = self.global_transform.basis
		kin_follow_node = new_follow_node
	
	stiffness = 600
	damping = 35
	configure_pos_joint()
	
	is_grabbing = true
	grabbed_obj = obj_to_grab


#			var joint := Generic6DOFJoint.new()
#			self.add_child(joint)
#			joint.global_transform = global_transform
#			joint.set_node_a("../" +self.get_path())
#			joint.set_node_b("../" +obj_to_grab.get_path())
#			grab_joint = joint
#
	
#			print("joint grabbing")


func drop():
	print(self.get_name() + " is dropping")
	offset_from_grabbed_obj = Vector3.ZERO
	
	if grab_joint != null:
		grab_joint.queue_free()
		grab_joint = null
	if kin_follow_node != null:
#		only queue_free if it it a temporary position 3D, as we went to keep the grab point which are area3D
		if kin_follow_node is Position3D:
			kin_follow_node.queue_free()
		elif kin_follow_node is Area:
			kin_follow_node.remove_hand(self)
			
	grabbed_obj = null
	if mode == MODE_KINEMATIC:
#		global_transform.origin = body.global_transform.origin - target_pos + offset
		mode = MODE_RIGID
	if pos_joint != null && self.is_in_group("hand") && is_grabbing:
		if pos_joint.get_node(pos_joint.get_node_b()) != self:
			
			pos_joint.global_transform.basis = body.global_transform.basis
			pos_joint.set_node_b("../" + get_path_to(self))
			offset = body.global_transform.origin - self.global_transform.origin + manual_offset
			collision_layer = original_collision_layer
			collision_mask = original_collision_mask
	
	is_grabbing = false
	
	
func _physics_process(delta):
			#position
			if mode == MODE_KINEMATIC:
				if kin_follow_node != null:
					global_transform.origin = kin_follow_node.global_transform.origin + offset_from_grabbed_obj
					global_transform.basis = kin_follow_node.global_transform.basis
					
			if !is_stable:
				target_pos += offset + offset_from_grabbed_obj
			
			
			if pos_joint != null:
				pos_joint.set("linear_spring_x/equilibrium_point", clamp(target_pos.x,-max_length.x, max_length.x))
				pos_joint.set("linear_spring_y/equilibrium_point", clamp(target_pos.y,-max_length.y, max_length.y))
				pos_joint.set("linear_spring_z/equilibrium_point", clamp(target_pos.z,-max_length.z, max_length.z))
			
			print(self.get_name() + ":" +String(global_transform.origin))
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

					var angle_minus :=  target_basis.get_euler().z - global_transform.basis.get_euler().z
					var angle_plus :=  PI - target_basis.get_euler().z - global_transform.basis.get_euler().z
					var angle : float
					if abs(angle_minus) < abs(angle_plus):
						angle = angle_minus
					else:
						angle = angle_plus
#					print(angle/TAU)
					error_roll = transform.basis.z * angle
#					var cross_p_roll :Vector3 = target_basis.x.cross(transform.basis.x)
#					if target_basis.x.x > 0 && target_basis.y.y > 0 || target_basis.z.z > 0:
#						if cross_p_roll.z >= 0 :
#							error_roll = transform.basis.z * - cross_p_roll.length()
#						else:
#							error_roll = transform.basis.z *  cross_p_roll.length()
#					else:
#						if cross_p_roll.z >= 0 :
#							error_roll = transform.basis.z * cross_p_roll.length()
#						else:
#							error_roll = transform.basis.z * - cross_p_roll.length()
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
#		print(current_error*PID_to_roll.x + integral_t *PID_to_roll.y + deriv*PID_to_roll.z)
		return current_error*PID_to_roll.x + integral_t *PID_to_roll.y + deriv*PID_to_roll.z
#

