extends RigidBody

var move_direction:= Vector2.ZERO
var target_height :float = -10
export var feet : Array
var active_foot : int = 0
var lowering_foot := 3

export var forward_step_length : float = 3
#export var backward_step_length : float = 2
export var side_step_length : float = 3

func _physics_process(delta):
	var move = move_direction * Vector2(side_step_length, forward_step_length)
	var step_length = move.length()
	
	for foot_p in feet:
		var foot = get_node(foot_p)
		if foot.is_grabbing && move.length() > 0:
#			print("feet grabbing")
			
			foot.target_pos = - Vector3(move.x,- target_height,move.y) + Vector3(foot.offset.x,0,foot.offset.z)
#			print(foot.target_pos)
			if feet.find(foot_p) == active_foot:
				change_active_foot()
				lowering_foot = 3
		elif feet.find(foot_p) == active_foot && move.length() > 0:
				foot.target_pos = Vector3(move.x/2,target_height/step_length,move.y/2) + Vector3(foot.offset.x,0,foot.offset.z)
				
				if Input.is_action_just_pressed("ui_select") || lowering_foot == feet.find(foot_p) \
				 || (Vector2(foot.global_transform.origin.x - global_transform.origin.x, foot.global_transform.origin.z - global_transform.origin.z).length()) > step_length/2 \
				 && (global_transform.origin.y - foot.global_transform.origin.y) < abs(target_height)/step_length + 1:
					lowering_foot = feet.find(foot_p)
					foot.target_pos = Vector3(move.x,target_height,move.y) + Vector3(foot.offset.x,0,foot.offset.z)
					foot.grab()
#
					
					if lowering_foot == 1:
						get_node(feet[0]).drop()
					else:
						get_node(feet[1]).drop()
		elif move.length() > 0:
			foot.target_pos = Vector3(0,target_height,0)
			
		else:
			foot.target_pos = Vector3(foot.offset.x,target_height,foot.offset.z)

					
func change_active_foot():
	print("swap")
	if active_foot +1 < feet.size():
		active_foot += 1
	else:
		active_foot = 0
