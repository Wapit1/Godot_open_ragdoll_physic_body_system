extends RigidBody


export var controller_p : NodePath
onready var controller : = get_node(controller_p)

var grab_obj := []
var grab_joint := []

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

func grab():
	if get_colliding_bodies().size() > 1:
		print("too many body")
	elif get_colliding_bodies().size() > 0:
		var obj = get_colliding_bodies()[0]
		var joint := Generic6DOFJoint.new()
		
		self.add_child(joint)
		joint.global_transform = global_transform
		joint.set_node_a(self.get_path())
		joint.set_node_b(obj.get_path())
		grab_joint.append(joint)
#		grab_obj.append(obj)
		
		print("grabbing")
		
func grip_end():
	drop()

func drop():
	for j in grab_joint:
		j.queue_free()
		grab_joint.erase(j)
		
