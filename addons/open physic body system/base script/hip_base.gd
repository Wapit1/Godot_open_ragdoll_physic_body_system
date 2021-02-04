extends RigidBody

var move_direction:= Vector3.ZERO
export var max_height :float = 10
export var min_height : float = 5
var target_height :float = 10
export var feet : Array
export var slam_force : float = 2
export var num_simultanous_active_foot : int = 1

var active_feet_index : Array = []
var lowering_feet_index : Array = []



var previous_move : = Vector3.ZERO

export var forward_step_length : float = 5
#export var backward_step_length : float = 2
export var side_step_length : float = 4

func _ready():
	var num_simultanous_active_foot_to_setup = num_simultanous_active_foot
	while num_simultanous_active_foot_to_setup > 0:
		active_feet_index.append(feet.size()+1)
		num_simultanous_active_foot_to_setup -= 1
		
	target_height = max_height +0.1
	drop_all()
func _physics_process(delta):
	if target_height > max_height:
		target_height -= delta* 10
	elif target_height < min_height:
		target_height += delta* 10
	
	feet_locomotion()
	
func feet_locomotion():
	var move : Vector3 = move_direction * Vector3(side_step_length, 0, forward_step_length)
	var v_h = Vector3(0,-target_height,0)
	var move_h = move + v_h
	var step_length = move.length()
	
	for foot_p in feet:
		var foot = get_node(foot_p)
		var foot_num = feet.find(foot_p)
		
		if foot.is_grabbing && move.length() > 0:
			foot.target_pos = - move + v_h + foot.offset
			
			if lowering_feet_index.has(foot_num):
				lowering_feet_index.erase(foot_num)
			if active_feet_index.has(foot_num):
					change_active_feet_index(active_feet_index.find(foot_num))

		elif (active_feet_index.has(foot_num)  || lowering_feet_index.has(foot_num) )&& move.length() > 0 :
			
				foot.target_pos = move + v_h/step_length + foot.offset
				
				if   lowering_feet_index.has(foot_num) \
				 || ((foot.transform.origin - transform.origin)+ move).length() > 0 \
				 && (global_transform.origin.y - foot.global_transform.origin.y) < abs(target_height)/step_length + 1:
					
					if  !lowering_feet_index.has(foot_num):
						lowering_feet_index.append(foot_num) 
					foot.target_pos = move + v_h * slam_force  + foot.offset
					if !foot.is_grabbing && target_height < max_height:
						foot.grab()
					
					
					
		elif move.length() > 0:
			foot.target_pos = -move + v_h * 0.9
			
		else:
			if foot.is_grabbing:
				foot.drop()
			foot.target_pos = v_h + foot.offset
			for i in active_feet_index:
				active_feet_index[active_feet_index.find(i)] = feet.size()+1
#				print(active_feet_index)

	if active_feet_index.has(feet.size()+1) && previous_move != move && previous_move.length() == 0 :
		print("reset")
		for active_foot in active_feet_index:
			var fartest_foot_index : int = 0
			while active_feet_index.has(fartest_foot_index):
				fartest_foot_index += 1
			var fartest_foot = get_node(feet[fartest_foot_index])
			for foot_p in feet:
				var foot = get_node(foot_p)
				var foot_num = feet.find(foot_p)
				
				if !active_feet_index.has(foot_num):
					
					if (fartest_foot.transform.origin - transform.origin+ move).length() < (foot.transform.origin- transform.origin + move).length():
						fartest_foot = foot
						print(feet.find(get_path_to(fartest_foot)))
			active_feet_index[active_feet_index.find(active_foot)] = feet.find(get_path_to(fartest_foot))
		print("reset_new_active_feet_index:" + String(active_feet_index))
	
	previous_move = move
func change_active_feet_index(num):
	
	
	
	var attempt_new_active_foot =(active_feet_index[num]+ num_simultanous_active_foot)% feet.size()
	
	while active_feet_index.has(attempt_new_active_foot):
		attempt_new_active_foot = (attempt_new_active_foot + 1)% feet.size()
	active_feet_index[num] = attempt_new_active_foot
	
	get_node(feet[active_feet_index[num]]).drop()
	
	print("swap_new_active_feet_index:" + String(active_feet_index))
func drop_all():
	for foot in feet:
		get_node(foot).drop()
