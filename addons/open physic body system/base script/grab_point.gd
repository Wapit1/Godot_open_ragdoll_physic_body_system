extends Area

#set the priority when grabbing in the general area, the highest number is picked when grabbing cannot choose, normal staticbody have a priority of 0 and rigidbody a priority of 1 for the hand -1 for the rest
export var grabbing_priority : float = 2


var number_of_hand_grabbing :int = 0
var hand_grabbing := []
#array to allow multiple hand grabbing, note that if it is a bar grabbing only the y and z axis will be taken into account as the x axis slides around
export var hand_position := Vector3.ZERO

# every variable below currently have no effect 
export var hand_pose := [[]]


#for bar grabbing like you would a slide one of your hand on a spear, 
#note that it slide on the x axis of the grab point so orient your area in accordance:
#enable it
export var is_bar_grab_enable := false

#set the max and min distance it can go before stopping or sliding off
export var max_distance_bar_grab : float = 1
export var min_distance_bar_grab : float = -1

#set if you want to have the hand slide off if you go too far 
export var can_slide_off_max :bool = false
export var can_slide_off_min :bool = false 

#the amount of force require to keep the hand from slipping 
export (float, 0, 1) var min_pressure_require_for_static = 0

func _ready():
	add_to_group("grab_point")
	connect("body_entered",self,"on_body_entered")
	connect("body_exited",self,"on_body_exited")
	
func on_body_entered(body):
	if body.is_in_group("hand"):
		body.can_grab_array.append(self)
func on_body_exited(body):
	if body.is_in_group("hand") && body.can_grab_array.has(self) :
		body.can_grab_array.erase(self)

func add_hand(new_hands):
	number_of_hand_grabbing += 1
	hand_grabbing.append(new_hands)
#	 add changing finger poses
#	for hand in hand_grabbing:
#		hand.offset_from_grabbed_obj = hand_pose[number_of_hand_grabbing][number_of_hand_grabbing]
 

func remove_hand(hand_to_remove):
	number_of_hand_grabbing -= 1
	hand_grabbing.erase(hand_to_remove)
#	for hand in hand_grabbing:
#		hand.offset_from_grabbed_obj = hand_pose[number_of_hand_grabbing][number_of_hand_grabbing]
