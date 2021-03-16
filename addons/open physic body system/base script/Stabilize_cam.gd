extends Spatial

export var track_spatial_p : NodePath
onready var track_spatial := get_node(track_spatial_p)



export var movement_hip_p : NodePath
onready var hip := get_node(movement_hip_p)

var average_pos_array : Array = []
export var num_of_average_pos : int = 50

onready var offset :Vector3 = global_transform.origin - track_spatial.global_transform.origin 

export var maximum_deviation_while_standing_still : float = 5
export var maximum_deviation_while_moving : float = 1

var is_following : bool = true
var was_moving : bool = false
var previous_height :float =0

func _ready():
	var num_to_setup = num_of_average_pos
	while num_to_setup > 0:
		average_pos_array.append(global_transform.origin)
		num_to_setup -= 1
func _physics_process(delta):
#		print(global_transform.origin- track_spatial.transform.origin)
		
		var height_offset = hip.height_offset
		var track_pos = track_spatial.global_transform.origin
		if average_pos_array.size() > num_of_average_pos:
			average_pos_array.remove(0)
		elif average_pos_array.size() >= 0:
			average_pos_array.append(track_pos + offset + Vector3(0,height_offset,0))
		
		var global_target_pos := Vector3.ZERO # in global pos
		
		for pos in average_pos_array:
			global_target_pos += pos
		
		global_target_pos = global_target_pos / average_pos_array.size()
		if hip.input_direction.length() > 0:
			
			
			if !was_moving :
#				clear for instant following when starting to move
				var previous_pos = average_pos_array[-1]
#				average_pos_array.clear()
#				average_pos_array.append(previous_pos)
				was_moving = true
#
			
			
			average_pos_array.append((track_pos + offset)*Vector3(1,0,1) + Vector3(0,global_target_pos.y,0))
			
			for pos in average_pos_array:
				global_target_pos.y += pos.y
			global_target_pos.y = global_target_pos.y / average_pos_array.size()
			
#			if (global_target_pos - track_pos +offset).length() >= maximum_deviation_while_moving:
#				global_target_pos -= (global_target_pos - track_pos+offset).normalized() * ((global_target_pos - track_pos+offset).length() -  maximum_deviation_while_moving)
##				average_pos_array.clear()
#				average_pos_array.append(global_target_pos)
			global_transform.origin = (track_pos + offset)*Vector3(1,0,1) + Vector3(0,global_target_pos.y,0)
			
		
		elif is_following:
			if was_moving:
				average_pos_array.clear()
				global_target_pos = (track_pos + offset + Vector3(0,height_offset,0))
				was_moving = false
				
			average_pos_array.append(track_pos + offset + Vector3(0,height_offset,0))
			global_transform.origin = global_target_pos
#		else:
#			print("hmd isn't following")


#	prototype code:
		
#		var height_offset = hip.height_offset
#		var track_pos = track_spatial.global_transform.origin
#
#
#
#		var global_target_pos :Vector3= track_pos + offset + Vector3(0,height_offset,0)
#
#
#
#
#		if hip.input_direction.length() > 0:
#
##			else:
#			if !was_moving :
##				clear for instant following when starting to move
#
#					var previous_height = global_target_pos.y
#					average_pos_array.clear()
#					was_moving = true
#
#
#
#			average_pos_array.append(Vector3(track_pos.x + offset.x,global_target_pos.y,track_pos.z + offset.z) )
#
#			for pos in average_pos_array:
#				global_target_pos += pos
#			global_target_pos = global_target_pos / average_pos_array.size()
#
#
#
#
#
#
##			if (global_target_pos - track_pos).length() >= maximum_deviation_while_moving:
##				global_target_pos -= (global_target_pos - track_pos).normalized() * ((global_target_pos - track_pos).length() -  maximum_deviation_while_moving)
##				average_pos_array.clear()
##				average_pos_array.append(global_target_pos)
##			global_transform.origin = global_target_pos
#		elif is_following:
#
#			if is_following:
#				average_pos_array.remove(0)
#				average_pos_array.append(track_pos + offset + Vector3(0,height_offset,0))
#
#
#			for pos in average_pos_array:
#				global_target_pos += pos
#			global_target_pos = global_target_pos / average_pos_array.size()
#
##			if (global_target_pos - track_pos).length() >= maximum_deviation_while_standing_still:
##				global_target_pos -= (global_target_pos - track_pos).normalized() * ((global_target_pos - track_pos).length() -  maximum_deviation_while_standing_still)
##				average_pos_array.clear()
##				average_pos_array.append(global_target_pos)
#
#			global_transform.origin = global_target_pos
#			was_moving = false
#		else:
#
#			 if hip.has_method("hmd_catching_up_to"):
#				if hip.is_catching_up_to_hmd:
		
