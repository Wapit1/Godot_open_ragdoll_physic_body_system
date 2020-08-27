extends Generic6DOFJoint


export var follow_nodepath : NodePath
onready var follow_node : Spatial = get_node(follow_nodepath) 

export var center_nodepath : NodePath
onready var center_node : Spatial = get_node(center_nodepath)


export var stiffness : float = 20.0
export var damping :float = 1


export var multiplier :int = 1
export var negative : bool = false
var offset :Vector3 = Vector3.ZERO

export var can_rotate : bool = false
export var rot_stiffness : float = 5.0
export var rot_damping : float   = 0.8

export var disable : = false
export var max_lenght : Vector3 = Vector3.INF

func _ready():
	
	if !disable:
#		set the starting offset, would probably need to take the rotation offset into accound too
		offset = get_node(get_node_b()).global_transform.origin - get_node(get_node_a()).global_transform.origin
		
		
#		set as spring
		set("linear_limit_x/enabled",false)
		set("linear_spring_x/enabled",true)
		set("linear_limit_y/enabled",false)
		set("linear_spring_y/enabled",true)
		set("linear_limit_z/enabled",false)
		set("linear_spring_z/enabled",true)
		set("linear_spring_x/stiffness",stiffness)
		set("linear_spring_y/stiffness",stiffness)
		set("linear_spring_z/stiffness",stiffness)
	#	print(get("linear_spring_x/stiffness"))
		set("linear_spring_x/damping",damping)
		set("linear_spring_y/damping",damping)
		set("linear_spring_z/damping",damping)
	
#	print(get("linear_spring_x/damping"))
		if max_lenght.length() != INF:
			set("linear_spring_x/upper_distance",max_lenght.z)
			set("linear_spring_y/upper_distance",max_lenght.z)
			set("linear_spring_z/upper_distance",max_lenght.z)
			
			set("linear_limit_x/enabled",true)
			set("linear_limit_y/enabled",true)
			set("linear_limit_z/enabled",true)
	#		print_debug('max_lenght active')

		if can_rotate:
			set("angular_limit_x/enabled",false)
			set("angular_spring_x/enabled",true)
			set("angular_limit_y/enabled",false)
			set("angular_spring_y/enabled",true)
			set("angular_limit_z/enabled",false)
			set("angular_spring_z/enabled",true)
			
			set("angular_spring_x/stiffness",rot_stiffness)
			set("angular_spring_y/stiffness",rot_stiffness)
			set("angular_spring_z/stiffness",rot_stiffness)
		
			set("angular_spring_x/damping",rot_damping)
			set("angular_spring_y/damping",rot_damping)
			set("angular_spring_z/damping",rot_damping)
	else: # if is disabled
		set_physics_process(false)
		
func _physics_process(delta):
	if follow_node != null && !disable:
		var follow_origin :Vector3 = (follow_node.global_transform.origin - center_node.global_transform.origin)
		follow_origin = (follow_origin+ offset) * multiplier
		if negative:
			follow_origin = -follow_origin
		# needs to take rotation of the bodies into account
		
		
		set("linear_spring_x/equilibrium_point", clamp(follow_origin.x,-max_lenght.x, max_lenght.x))
		set("linear_spring_y/equilibrium_point", clamp(follow_origin.y,-max_lenght.y, max_lenght.y))
		set("linear_spring_z/equilibrium_point", clamp(follow_origin.z,-max_lenght.z, max_lenght.z))
		
		if can_rotate:
			set("angular_spring_x/equilibrium_point", follow_node.global_transform.basis.get_euler().x)
			set("angular_spring_y/equilibrium_point", follow_node.global_transform.basis.get_euler().y)
			set("angular_spring_z/equilibrium_point", follow_node.global_transform.basis.get_euler().z)
