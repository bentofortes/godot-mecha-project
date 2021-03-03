extends KinematicBody
class_name Player


const MOUSE_SENSITIVITY = 0.01
const MOVE_ACCELERATION = 0.05
const MOVE_INERTIA = 0.02
const MOVE_SPEED = 1

var is_moving_x
var is_moving_y
var is_moving_z

var prev_transform = Vector3()

var input_x_axis = 0
var input_y_axis = 0
var input_z_axis = 0
var velocity = Vector3(0,0,0)


onready var camera = self.get_child(2)


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	is_moving_x = false
	is_moving_y = false
	is_moving_z = false
	return


func _unhandled_input(event):

	if (
		!(event is InputEventMouseMotion)
	):
		return

	if (event is InputEventMouseMotion):
		rotation_degrees.y -= MOUSE_SENSITIVITY * event.relative.x


func _get_input():
	
	velocity = Vector3()
	
	var current_acceleration = MOVE_ACCELERATION
	if (is_moving_x and is_moving_z):
		current_acceleration = MOVE_ACCELERATION/2
	
	if (Input.is_action_pressed("a")):
		is_moving_z = true
		input_z_axis -= MOVE_ACCELERATION
		input_z_axis = max(input_z_axis, -MOVE_SPEED)
	if (Input.is_action_pressed("d")):
		is_moving_z = true
		input_z_axis += MOVE_ACCELERATION
		input_z_axis = min(input_z_axis, MOVE_SPEED)
		
	if (Input.is_action_pressed("w")):
		is_moving_x = true
		input_x_axis += MOVE_ACCELERATION
		input_x_axis = min(input_x_axis, MOVE_SPEED)
	if (Input.is_action_pressed("s")):
		is_moving_x = true
		input_x_axis -= MOVE_ACCELERATION
		input_x_axis = max(input_x_axis, -MOVE_SPEED)
		
	if (Input.is_action_pressed("space")):
		is_moving_y = true
		input_y_axis += MOVE_ACCELERATION
		input_y_axis = min(input_y_axis, MOVE_SPEED)
	if (Input.is_action_pressed("shift")):
		is_moving_y = true
		input_y_axis -= MOVE_ACCELERATION
		input_y_axis = max(input_y_axis, -MOVE_SPEED)
		
	velocity = Vector3(input_x_axis, input_y_axis, input_z_axis)
	var horizontal_v = Vector3(input_x_axis, 0, input_z_axis)
	if (pow(horizontal_v.length_squared(), 1/2) > 1):
		horizontal_v = horizontal_v.normalized()
	horizontal_v = horizontal_v.rotated(Vector3(0,1,0), self.rotation.y)
	velocity = Vector3(horizontal_v.x, input_y_axis, horizontal_v.z)
	
		
	
func _physics_process(delta):
	_get_input()
	move_and_slide(velocity * 10)
	
	if (!is_moving_x and input_x_axis != 0):
		if (input_x_axis > 0):
			input_x_axis -= MOVE_ACCELERATION
			input_x_axis = max(input_x_axis, 0)
		if (input_x_axis < 0):
			input_x_axis += MOVE_ACCELERATION
			input_x_axis = min(input_x_axis, 0)
			
	if (!is_moving_y and input_y_axis != 0):
		if (input_y_axis > 0):
			input_y_axis -= MOVE_ACCELERATION
			input_y_axis = max(input_y_axis, 0)
		if (input_y_axis < 0):
			input_y_axis += MOVE_ACCELERATION
			input_y_axis = min(input_y_axis, 0)
			
	if (!is_moving_z and input_z_axis != 0):
		if (input_z_axis > 0):
			input_z_axis -= MOVE_ACCELERATION
			input_z_axis = max(input_z_axis, 0)
		if (input_z_axis < 0):
			input_z_axis += MOVE_ACCELERATION
			input_z_axis = min(input_z_axis, 0)
	
	var slide_count = get_slide_count()
	if slide_count:
		var collision = get_slide_collision(slide_count - 1)
		if collision:
			var aux2 = collision.normal
			var aux = aux2.rotated(Vector3(0,1,0), self.rotation.y)
#			print(self.get_floor_velocity())
			if (pow(aux.x, 2) >= 0.9):
				input_x_axis = 0
				is_moving_x = false
				print("x", aux2, aux)
			if (pow(aux.y, 2) >= 0.9):
				input_y_axis = 0
				is_moving_y = false
				print("y")
				
			if (pow(aux.z, 2) >= 0.9):
				input_z_axis = 0
				is_moving_z = false
				print("z", aux2, aux)
				
#			if (pow(pow(aux.x, 2) + pow(aux.z, 2), 0.5)) >= 0.9:
#				input_z_axis = 0
#				input_x_axis = 0
#				is_moving_x = false
#				is_moving_z = false
#			if (pow(pow(aux.x, 2) + pow(aux.y, 2), 0.5)) >= 0.9:
#				input_y_axis = 0
#				input_x_axis = 0
#				is_moving_x = false
#				is_moving_y = false
#			if (pow(pow(aux.z, 2) + pow(aux.y, 2), 0.5)) >= 0.9:
#				input_y_axis = 0
#				input_z_axis = 0
#				is_moving_z = false
#				is_moving_y = false
			
	prev_transform = self.transform.origin
	
	is_moving_x = false
	is_moving_y = false
	is_moving_z = false



