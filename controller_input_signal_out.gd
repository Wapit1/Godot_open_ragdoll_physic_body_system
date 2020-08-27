extends ARVRController

signal trigger_start
signal trigger_while(axis)
signal trigger_end

signal grip_start
signal grip_while(axis)
signal grip_end

signal farb_start
signal farb_end

signal clob_start
signal clob_end

signal axis_press_start
signal axis_press_end

var button := [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
var axis := [0,0,0,0,0]

func _ready():
	connect("button_pressed", self, "button_pressed")
	connect("button_release", self, "button_released")

func button_pressed(button_index):
#	print("pressed"+ String(button_index))
	button[button_index] = 1
	if button_index == 1:
		emit_signal("farb_start")
	elif button_index == 2:
		emit_signal("grip_start")
	elif button_index == 7:
		emit_signal("clob_start")
	elif button_index == 14:
		emit_signal("axis_press_start")
	elif button_index == 15:
		emit_signal("trigger_start")

func button_released(button_index):
#	print("released"+String(button_index))
	button[button_index] = 0
	if button_index == 1:
		emit_signal("farb_end")
	elif button_index == 2:
		emit_signal("grip_end")
	elif button_index == 7:
		emit_signal("clob_end")
	elif button_index == 14:
		emit_signal("axis_press_end")
	elif button_index == 15:
		emit_signal("trigger_end")


func _process(delta):
	if button[15]:
		axis[2] = get_joystick_axis(2)
		emit_signal("trigger_while",get_joystick_axis(2))
	if button[2]:
		axis[4] = get_joystick_axis(4)
		emit_signal("grip_while",get_joystick_axis(4))
	axis[0] = get_joystick_axis(0)
	axis[1] = get_joystick_axis(1)
