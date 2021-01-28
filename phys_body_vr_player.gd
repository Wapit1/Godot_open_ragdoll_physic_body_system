extends RigidBody

var move_direction:= Vector2.ZERO
var target_height :float = -15
export var feet : Array
var active_foot : int = 0

func _physics_process(delta):
	
	for foot_p in feet :
		var foot = get_node(foot_p)
		if foot.is_grabbing:
			#drag foot backward to move forward
			foot.target_pos = -Vector3(move_direction.x,-target_height,move_direction.y) + Vector3(foot.offset.x,0,foot.offset.z)
			if Vector2(foot.transform.origin.x,foot.transform.origin.y).round() == move_direction + Vector2(foot.offset.x,foot.offset.z):
				foot.drop()
		elif feet.find(foot_p) == active_foot:
			foot.target_pos = Vector3(move_direction.x,target_height/2,move_direction.y) - Vector3(foot.offset.x,0,foot.offset.z)
#			print("move foot to target")
#			print(move_direction + Vector2(foot.offset.x,foot.offset.z) - Vector2(foot.transform.origin.x,foot.transform.origin.y))
			if Vector2(foot.transform.origin.x,foot.transform.origin.y).normalized() == (move_direction - Vector2(foot.offset.x,foot.offset.z)).normalized():
				#touch foot to ground
				print("touch foot to ground")
				foot.target_pos = Vector3(move_direction.x,target_height,move_direction.y) - Vector3(foot.offset.x,0,foot.offset.z)
				
				if foot.transform.origin.normalized() == (Vector3(move_direction.x,round(target_height),move_direction.y) - Vector3(foot.offset.x,0,foot.offset.z)).normalized():
					foot.grab()
					change_active_foot()
					print("foot touched ground")
		else:
			foot.target_pos = Vector3(foot.offset.x,target_height,foot.offset.z)
					
func change_active_foot():
	if active_foot +1 < feet.size():
		active_foot += 1
	else:
		active_foot = 0
