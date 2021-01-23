extends KinematicBody
onready var leftcontrol := $ARVROrigin/ARVRController
export var left_hand_p :NodePath
onready var left_hand := get_node(left_hand_p)
onready var rightcontrol := $ARVROrigin/ARVRController_2
export var right_hand_p :NodePath
onready var right_hand := get_node(right_hand_p)
onready var head := $ARVROrigin/ARVRCamera
onready var origin := $ARVROrigin
#onready var ground_ray := $RayCast
#onready var skeleton := $Skeleton
export var bodypath : NodePath
onready var body : = get_node(bodypath)
#onready var body_joint := $body_joint

var followbody := false

export var speed :int = 30  
export var vertical_speed : int = 10
var r_stick_pos :float =0 
var height_offset :float = 0
var prev_vel : Vector3

export var stiffness : float = 50
export var damping   : float = 10

func _ready():
#	skeleton.physical_bones_start_simulation(["LeftArm","RightArm","LeftUpLeg","RightUpLeg"])
	
	var VR = ARVRServer.find_interface('OpenVR')
	if VR && VR.initialize():
		get_viewport().arvr = true
		get_viewport().hdr = false
		OS.vsync_enabled = false
		Engine.target_fps = 144
	else:
		print('no interface')
	rightcontrol.connect("farb_start",self,"change_followbody")
#
#	body_joint.set("linear_spring_x/stiffness",stiffness)
##	body_joint.set("linear_spring_y/stiffness",stiffness)
#	body_joint.set("linear_spring_z/stiffness",stiffness)
#
#	body_joint.set("linear_spring_x/damping",damping)
##	body_joint.set("linear_spring_y/damping",damping)
#	body_joint.set("linear_spring_z/damping",damping)
#
	
func _physics_process(delta):
#		locomotion
		var vel := Vector3.ZERO
		var dir := Vector3.ZERO
		var cam_xform = head.get_global_transform()
		
		if leftcontrol.axis[1] > 0.5 :
			dir += - cam_xform.basis.z 
		elif leftcontrol.axis[1] < -0.5 :
			dir += cam_xform.basis.z 
			
		if leftcontrol.axis[0] < -0.5 :
			dir += - cam_xform.basis.x 
		elif leftcontrol.axis[0] > 0.5 :
			dir += cam_xform.basis.x 
		
		dir = dir.normalized()
		vel = dir * speed * delta
		if rightcontrol.axis[1] < -0.5 :
			vel.y = -1 * delta * vertical_speed
			height_offset += -1 * delta * vertical_speed
		elif rightcontrol.axis[1] > 0.5 :
			vel.y = 1 * delta * vertical_speed
			height_offset += 1 * delta * vertical_speed
			
			
			
		else:
			vel.y = 0
		
		if vel.length() != 0:
			move_and_collide(vel,false)
#			if prev_vel != vel:
#				body.apply_central_impulse((prev_vel-vel)*100)
#				left_hand.apply_central_impulse(vel-prev_vel)
#				right_hand.apply_central_impulse(vel-prev_vel)
		
		elif followbody:
			var follow_pos :Vector3 = body.global_transform.origin + Vector3(0,height_offset,0)
			var precision = 70
			if (follow_pos * precision).round() != (global_transform.origin* precision).round():
				move_and_collide(( follow_pos - global_transform.origin) * speed/2 * delta)
#			else:
#				followbody = false
		prev_vel = vel
		
		
		- head.global_transform.origin + global_transform.origin 
		
#		var bodytrans = body.transform
#		origin.transform.origin = Vector3(0,1.5,0)
		var oribas = origin.global_transform.basis
		
		global_transform.basis.x = head.global_transform.basis.x
		global_transform.basis.z = -head.global_transform.basis.z
		origin.global_transform.basis = oribas 
##		body.global_transform = bodytrans 
#		if head.global_transform.origin != global_transform.origin:
#			var ori_pos :Vector3 = origin.global_transform.origin
#			if !move_and_collide(head.global_transform.origin - Vector3(0,height_offset,0) -global_transform.origin,false,true,true):
#				origin.global_transform.origin = ori_pos 
#				global_transform.origin = head.global_transform.origin - Vector3(0,height_offset,0) 
#
#		____________________________________
#		snap turning currently not working well 
		if round(rightcontrol.axis[0]) != 0 :

			if round(rightcontrol.axis[0]) != round(r_stick_pos) :
				if rightcontrol.axis[0] > -0.75:
					rotate_y(-TAU/8)
					r_stick_pos = rightcontrol.axis[0]
				elif rightcontrol.axis[0] < 0.75:
					rotate_y(TAU/8)
					r_stick_pos = rightcontrol.axis[0]
		else:
			r_stick_pos = 0
			
#
#func change_followbody():
#
#	if followbody:
#		followbody = false
#	else:
#		followbody = true
	

