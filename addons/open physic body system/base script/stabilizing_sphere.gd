extends "res://addons/open physic body system/base script/phys_extremities.gd"

var target_rot := Vector3.ZERO

export var PID_rolling : Vector3 = Vector3(50,2,0)

var integral := Vector3.ZERO

var last_error := Vector3.ZERO
var previous_target_rot := Vector3.ZERO

func _physics_process(delta):
	
#	if (previous_target_rot*2).round() == (target_rot*2).round():
	add_torque(PID_calculate(target_rot-angular_velocity,delta))
#	angular_velocity = -target_rot * 100 doesn't work
#	else:
#		angular_velocity = Vector3.ZERO
	if previous_target_rot != target_rot:
		linear_velocity /= (previous_target_rot - target_rot).length() +1
		
#		linear_velocity = linear_velocity.rotated(Vector3.UP,target_rot.cross(angular_velocity).y)
#		angular_velocity = angular_velocity.rotated(Vector3.UP,target_rot.cross(angular_velocity).y)
	if target_rot.length() <= 0:
		linear_velocity = Vector3.ZERO  
		angular_velocity = Vector3.ZERO
	
	previous_target_rot = target_rot

func PID_calculate(current_error:Vector3, time:float):
	integral += current_error * time
	var deriv = (current_error - last_error) /time
	last_error = current_error
	return current_error*PID_rolling.x + integral *PID_rolling.y + deriv*PID_rolling.z
