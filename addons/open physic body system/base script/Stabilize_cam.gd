extends Spatial

export var track_spatial_p : NodePath
onready var track_spatial := get_node(track_spatial_p)



export var movement_hip_p : NodePath
onready var hip := get_node(movement_hip_p)

var average_pos_array : Array = []
export var num_of_average_pos : int = 50

onready var offset :Vector3 = global_transform.origin - track_spatial.global_transform.origin 


func _ready():
	var num_to_setup = num_of_average_pos
	while num_to_setup > 0:
		average_pos_array.append(global_transform.origin)
		num_to_setup -= 1
func _physics_process(delta):
#		print(global_transform.origin- track_spatial.transform.origin)
		
		var height_offset = hip.height_offset
		var track_pos = track_spatial.global_transform.origin
		average_pos_array.remove(0)
		average_pos_array.append(track_pos + offset + Vector3(0,height_offset,0))
		
		var target_pos := Vector3.ZERO
		
		for pos in average_pos_array:
			target_pos += pos
		
		target_pos = target_pos / average_pos_array.size()
		if hip.move_direction.length() > 0:
			global_transform.origin = Vector3(track_pos.x + offset.x,target_pos.y,track_pos.z + offset.z)
			average_pos_array.clear()
			average_pos_array.append(Vector3(track_pos.x + offset.x,target_pos.y,track_pos.z + offset.z))
		else:
			global_transform.origin = target_pos
			
		
