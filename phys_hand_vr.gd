extends "phys_extremities.gd"


export var controller_p : NodePath
onready var controller : = get_node(controller_p)


func _ready():
	
	#	controller.connect("trigger_start",self,"trigger_start")
	##	controller.connect("trigger_while",self,"trigger_while")
	#	controller.connect("trigger_end",self,"trigger_end")
	
		controller.connect("grip_start",self,"grip_start")
	#	controller.connect("grip_while",self,"grip_while")
		controller.connect("grip_end",self,"grip_end")
	#
	#	controller.connect("farb_start",self,"farb_start")
	#	controller.connect("farb_end",self,"farb_end")
	#
	#	controller.connect("farb_start",self,"farb_start")
	#	controller.connect("farb_end",self,"farb_end")
	#
	#	controller.connect("clob_start",self,"clob_start")
	#	controller.connect("clob_end",self,"clob_end")
	#
	#	controller.connect("axis_press_start",self,"axis_press_start")
	#	controller.connect("axis_press_end",self,"axis_press_end")

func grip_start():
	print("input received")
	grab()

func grip_end():
	drop()

func _physics_process(delta):
	target_pos = controller.global_transform.origin - body.global_transform.origin
	target_basis = controller.global_transform.basis

#

