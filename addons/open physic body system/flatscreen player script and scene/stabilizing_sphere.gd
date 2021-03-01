extends "res://addons/open physic body system/base script/phys_extremities.gd"

var target_rot := Vector3.ZERO

export var PID_rolling : Vector3 = Vector3(50,2,0)

var integral := Vector3.ZERO

var last_error := Vector3.ZERO

func _physics_process(delta):
	
	
	add_torque(PID_calculate(target_rot-angular_velocity,delta))
	
func PID_calculate(current_error:Vector3, time:float):
	integral += current_error * time
	var deriv = (current_error - last_error) /time
	last_error = current_error
	return current_error*PID_rolling.x + integral_z *PID_rolling.y + deriv*PID_rolling.z
