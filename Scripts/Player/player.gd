extends KinematicBody
class_name Player


const MOUSE_SENSITIVITY = 0.01
const MOVE_ACCELERATION = 0.05
const MOVE_INERTIA = 0.02
const MOVE_SPEED = 1

var is_moving_x
var is_moving_y
var is_moving_z
var camera_lock

var prev_transform = Vector3()

var input_x_axis = 0
var input_y_axis = 0
var input_z_axis = 0
var target_rotation = 0
var velocity = Vector3()
var horizontal_v = Vector3()


onready var collision = self.get_child(0)

onready var cameraArm = self.get_child(1)
onready var camera = cameraArm.get_child(0)

onready var view = get_viewport()


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	is_moving_x = false
	is_moving_y = false
	is_moving_z = false
	camera_lock = false
	return


func _unhandled_input(event):

	if (
		!(event is InputEventMouseMotion)
	):
		return

	if (event is InputEventMouseMotion):
		
		cameraArm.rotation_degrees.y -= MOUSE_SENSITIVITY * event.relative.x
		
		if (view.get_mouse_position().x <= 300):
			target_rotation = 1
			
#		print(view.get_mouse_position())
#		if (abs(cameraArm.rotation_degrees.y - collision.rotation_degrees.y) < 70) or (camera_lock):
#			var target_rotation = cameraArm.rotation_degrees.y - (MOUSE_SENSITIVITY * event.relative.x)
#			if (abs(target_rotation - collision.rotation_degrees.y) >= 70):
#				target_rotation = cameraArm.rotation_degrees.y
#			cameraArm.rotation_degrees.y = target_rotation


func _get_input():
	
	velocity = Vector3()
	
	var current_acceleration = MOVE_ACCELERATION
	if (is_moving_x and is_moving_z):
		current_acceleration = MOVE_ACCELERATION/pow(2, 0.5)
	
	if (Input.is_action_pressed("b")):
		camera_lock = true
	if (Input.is_action_just_released("b")):
		camera_lock = false
	
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
	horizontal_v = Vector3(input_x_axis, 0, input_z_axis)
	
	if (pow(horizontal_v.length_squared(), 1/2) > 1):
		horizontal_v = horizontal_v.normalized()
		
	horizontal_v = horizontal_v.rotated(Vector3(0,1,0), collision.rotation.y + PI/2)
	velocity = Vector3(horizontal_v.x, input_y_axis, horizontal_v.z)
	
	
func _physics_process(delta):
	_get_input()
	move_and_slide(velocity * 10)
	
#	if (abs(cameraArm.rotation_degrees.y - collision.rotation_degrees.y) >= 70) and (!camera_lock):
#		cameraArm.rotation_degrees.y -= (
#			(cameraArm.rotation_degrees.y - collision.rotation_degrees.y)/
#			(1.5 * abs(cameraArm.rotation_degrees.y - collision.rotation_degrees.y))
#		)
#
#	elif (cameraArm.rotation_degrees.y != collision.rotation_degrees.y) and (!camera_lock):
#		collision.rotation_degrees.y += (
#			(cameraArm.rotation_degrees.y - collision.rotation_degrees.y)/
#			(1.5 * abs(cameraArm.rotation_degrees.y - collision.rotation_degrees.y))
#		)
	
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
			var aux = collision.normal
			var angle = aux.angle_to(horizontal_v)
			
			if (pow(pow(angle, 2), 0.5) > PI - 0.5):
				horizontal_v = Vector3()
				input_x_axis = 0
				input_z_axis = 0
				
	prev_transform = self.transform.origin
	
	is_moving_x = false
	is_moving_y = false
	is_moving_z = false



