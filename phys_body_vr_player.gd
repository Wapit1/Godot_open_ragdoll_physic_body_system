extends RigidBody

var move_direction:= Vector3.ZERO
export var max_height :float = 10
export var min_height : float = 1
var target_height :float = 10
export var feet : Array
export var slam_force : float = 2
export var num_active_foot : int = 1

var active_foot_index : Array = []
var lowering_foot := 3


var previous_move : = Vector3.ZERO

export var forward_step_length : float = 3
#export var backward_step_length : float = 2
export var side_step_length : float = 4

func _ready():
	var num_active_foot_to_setup = num_active_foot
	while num_active_foot_to_setup > 0:
		active_foot_index.append(feet.size()+1)
		num_active_foot_to_setup -= 1
		
	target_height = max_height +1
	drop_all()
func _physics_process(delta):
	if target_height > max_height:
		target_height -= delta* 10
		
#	else:
	walk()
	
func walk():
	var move : Vector3 = move_direction * Vector3(side_step_length, 0, forward_step_length)
	var v_h = Vector3(0,-target_height,0)
	var move_h = move + v_h
	var step_length = move.length()
	
	for foot_p in feet:
		var foot = get_node(foot_p)
		var foot_num = feet.find(foot_p)
		
		if foot.is_grabbing && move.length() > 0:
			foot.target_pos = - move + v_h + foot.offset
			
			if active_foot_index.has(foot_num):
				change_active_foot_index(active_foot_index.find(foot_num))
				lowering_foot = feet.size() +1

		elif active_foot_index.has(foot_num)  && move.length() > 0:
			
				foot.target_pos = move + v_h/step_length + foot.offset
				
				if Input.is_action_just_pressed("ui_select") || lowering_foot == feet.find(foot_p) \
				 || ((foot.transform.origin - transform.origin)+ move).length() > 0 \
				 && (global_transform.origin.y - foot.global_transform.origin.y) < abs(target_height)/step_length + 1:
					
					lowering_foot = foot_num
					foot.target_pos = move + v_h * slam_force  + foot.offset
					if !foot.is_grabbing && target_height < max_height:
						foot.grab()
					
					if foot_num + 1 < feet.size():
						get_node(feet[foot_num + 1]).drop()
					else:
						get_node(feet[0]).drop()
		elif move.length() > 0:
			foot.target_pos = -move + v_h * 0.9
			
		else:
			if foot.is_grabbing:
				foot.drop()
			foot.target_pos = v_h + foot.offset
			for i in active_foot_index:
				active_foot_index[active_foot_index.find(i)] = feet.size()+1
#				print(active_foot_index)

	if active_foot_index.has(feet.size()+1) && previous_move != move && previous_move.length() == 0 :
		print("reset")
		for active_foot in active_foot_index:
			var fartest_foot_index : int = 0
			while active_foot_index.has(fartest_foot_index):
				fartest_foot_index += 1
			var fartest_foot = get_node(feet[fartest_foot_index])
			for foot_p in feet:
				var foot = get_node(foot_p)
				var foot_num = feet.find(foot_p)
				
				if !active_foot_index.has(foot_num):
					
					if (fartest_foot.transform.origin - transform.origin+ move).length() < (foot.transform.origin- transform.origin + move).length():
						fartest_foot = foot
						print(feet.find(get_path_to(fartest_foot)))
			active_foot_index[active_foot_index.find(active_foot)] = feet.find(get_path_to(fartest_foot))
		print("reset_new_active_foot_index:" + String(active_foot_index))
	
	previous_move = move
func change_active_foot_index(num):
	
	active_foot_index[num] =(active_foot_index[num]+ num_active_foot)% feet.size()
	
#	print("swap_new_active_foot_index:" + String(active_foot_index))
func drop_all():
	for foot in feet:
		get_node(foot).drop()
