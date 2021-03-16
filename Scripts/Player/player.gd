extends KinematicBody
class_name Player


const SHRINK = 3.0
const SCREEN_PAN_OUTER_H = 200/SHRINK
const SCREEN_PAN_INNER_H = 500/SHRINK
const SCREEN_PAN_OUTER_V = 50/SHRINK
const SCREEN_PAN_INNER_V = 250/SHRINK
const PAN_DIFF_H = SCREEN_PAN_INNER_H - SCREEN_PAN_OUTER_H
const PAN_DIFF_V = SCREEN_PAN_INNER_V - SCREEN_PAN_OUTER_V
const SCREEN_V = 1080/SHRINK
const SCREEN_H = 1920/SHRINK


const MOUSE_SENSITIVITY = 0.01
const MOVE_ACCELERATION = 0.8
const MOVE_INERTIA = 0.6 #0.5
const MOVE_SPEED = 16
const HYPOTENUSE_MOVE_SPEED = sqrt(2 * pow(16, 2))
const CONCURRENT_SCALE = 1.0/sqrt(2)
const JUMP_ACCELERATION = 2
const JUMP_SPEED = 24
const GRAVITY = -40
const GRAVITY_ACCELERATION = 1.2
const MAX_BOOST = 1.4


const MAX_CAMERA_ROT_Y = 24
var INIT_CAMERA_ROT_X = 0
const MAX_CAMERA_ROT_X = 16


var is_moving_x
var is_moving_y
var is_moving_z
var is_falling

var prev_origin = Vector3()
var current_forward = Vector3()
var current_v = Vector3()

var input_y_axis = -GRAVITY_ACCELERATION
var input_x_axis = 0
var input_x_vector = Vector3()
var x_residual = Vector3()
var input_z_axis = 0
var input_z_vector = Vector3()
var z_residual = Vector3()
var target_rotation = 0
var camera_target_rotation_h = 0
var camera_target_rotation_v = 0
var scale_factor = 1
var velocity = Vector3()
var residual_v = Vector3()
var horizontal_v = Vector3()
var boost = 1


const MAIN_COOL_MAX = 0.08
var mainCool = 0


var mainProjectile = preload("res://Scenes/PreFabs/Main_Projectile.tscn")
var ProjectileTest = preload("res://Scenes/PreFabs/Projectile_test.tscn")


onready var parent = self.get_parent()
onready var hurtBox = $Collision
onready var cameraArm = $CameraArm
onready var camera :CustomCamera = $CameraArm/Camera
onready var mainPos :Position3D = $main

onready var view = get_viewport()


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	prev_origin = self.global_transform.origin
	is_moving_x = false
	is_moving_y = false
	is_moving_z = false
	is_falling = false
	
	INIT_CAMERA_ROT_X = cameraArm.rotation_degrees.x
	
	
	
	return


func _unhandled_input(event):

	if (
		!(event is InputEventMouseMotion) and
		!(Input.is_action_just_pressed("shift")) and
		!(Input.is_action_just_released("shift")) and
		!(Input.is_action_just_pressed("lClick")) and
		!(Input.is_action_just_pressed("f11"))
	):
		return
		
	if (Input.is_action_just_pressed("f11")):
		OS.window_fullscreen = !OS.window_fullscreen
		print(get_viewport().get_visible_rect())
		
	if (Input.is_action_just_pressed("shift")):
		boost = MAX_BOOST
	if (Input.is_action_just_released("shift")):
		boost = 1

	if (event is InputEventMouseMotion):
		var aux = view.get_mouse_position()
		if (aux.x <= SCREEN_PAN_INNER_H):
			if (aux.x <= SCREEN_PAN_OUTER_H):
				aux.x = SCREEN_PAN_OUTER_H
				view.warp_mouse(aux)
			camera_target_rotation_h = abs(aux.x - SCREEN_PAN_INNER_H)/PAN_DIFF_H
			
		elif (aux.x >= SCREEN_H - SCREEN_PAN_INNER_H):
			if (aux.x >= SCREEN_H - SCREEN_PAN_OUTER_H):
				aux.x = SCREEN_H - SCREEN_PAN_OUTER_H
				view.warp_mouse(aux)
			camera_target_rotation_h = -abs(aux.x - (SCREEN_H - SCREEN_PAN_INNER_H))/PAN_DIFF_H
			
		else:
			camera_target_rotation_h = 0
			
		if (aux.y <= SCREEN_PAN_INNER_V):
			if (aux.y <= SCREEN_PAN_OUTER_V):
				aux.y = SCREEN_PAN_OUTER_V
				view.warp_mouse(aux)
			camera_target_rotation_v = -abs(aux.y - SCREEN_PAN_INNER_V)/PAN_DIFF_V
			
		elif (aux.y >= SCREEN_V - SCREEN_PAN_INNER_V):
			if (aux.y >= SCREEN_V - SCREEN_PAN_OUTER_V):
				aux.y = SCREEN_V - SCREEN_PAN_OUTER_V
				view.warp_mouse(aux)
			camera_target_rotation_v = abs(aux.y - (SCREEN_V - SCREEN_PAN_INNER_V))/PAN_DIFF_V
			
		else:
			camera_target_rotation_v = 0


func _get_input():
	if (Input.is_action_pressed("lClick")):
		self._shoot_main()
		
	velocity = Vector3()
	
	if (Input.is_action_pressed("space")) and !self.is_on_floor():
		is_moving_y = true
		input_y_axis += JUMP_ACCELERATION
		input_y_axis = min(input_y_axis, JUMP_SPEED)
	if (Input.is_action_just_pressed("space")) and self.is_on_floor():
		is_moving_y = true
		input_y_axis += 8 * JUMP_ACCELERATION
		input_y_axis = min(input_y_axis, JUMP_SPEED)
	
	if (Input.is_action_pressed("q")): target_rotation = 1
	if (Input.is_action_pressed("e")): target_rotation = -1
		
	if !self.is_on_floor() or is_moving_y:
		input_y_axis -= GRAVITY_ACCELERATION
		input_y_axis = max(input_y_axis, GRAVITY)
	else:
		input_y_axis = -GRAVITY_ACCELERATION
	
	#Horizontal
	if (Input.is_action_pressed("s")):
		is_moving_z = true
		input_z_axis -= MOVE_ACCELERATION * boost * scale_factor
		input_z_axis = max(input_z_axis, -MOVE_SPEED * boost)
		input_z_vector = Vector3(0, 0, input_z_axis)
		
	if (Input.is_action_pressed("w")):
		is_moving_z = true
		input_z_axis += MOVE_ACCELERATION * boost * scale_factor
		input_z_axis = min(input_z_axis, MOVE_SPEED * boost)
		input_z_vector = Vector3(0, 0, input_z_axis)
		
	if (Input.is_action_pressed("a")):
		is_moving_x = true
		input_x_axis += MOVE_ACCELERATION * boost * scale_factor
		input_x_axis = min(input_x_axis, MOVE_SPEED * boost)
		input_x_vector = Vector3(input_x_axis, 0, 0)
		
	if (Input.is_action_pressed("d")):
		is_moving_x = true
		input_x_axis -= MOVE_ACCELERATION * boost * scale_factor
		input_x_axis = max(input_x_axis, -MOVE_SPEED * boost)
		input_x_vector = Vector3(input_x_axis, 0, 0)
		
	if is_moving_z:
		input_z_vector = input_z_vector.rotated(Vector3.UP, self.rotation.y)
	else:
		residual_v += input_z_vector
		input_z_vector = Vector3()
		input_z_axis = 0
		
	if is_moving_x:
		input_x_vector = input_x_vector.rotated(Vector3.UP, self.rotation.y)
	else:
		residual_v += input_x_vector
		input_x_vector = Vector3()
		input_x_axis = 0
		
	if is_moving_x and is_moving_z:
		scale_factor = CONCURRENT_SCALE
	else: scale_factor = 1
		
	var aux = residual_v.length()
	if aux > 0:
		residual_v = residual_v.normalized() * (aux - MOVE_INERTIA)
		if aux - MOVE_INERTIA < 1:
			residual_v = Vector3()
		
	horizontal_v = input_x_vector + input_z_vector + residual_v
	
	if horizontal_v.length_squared() > pow(MOVE_SPEED * boost, 2):
		horizontal_v = horizontal_v.normalized() * MOVE_SPEED * boost
	
	velocity = Vector3(horizontal_v.x,input_y_axis,horizontal_v.z)
	
func _physics_process(delta):
	_get_input()
	camera.place_crosshair()
	move_and_slide(velocity, Vector3.UP)
	_custom_rotate()
	
	current_forward = Vector3.BACK.rotated(Vector3.UP, self.rotation.y)
	
	var slide_count = get_slide_count()
	if slide_count:
		var collision = get_slide_collision(slide_count - 1)
		
		if collision:
			var aux = collision.normal
			var angle = aux.angle_to(horizontal_v)
			
			if (pow(pow(angle, 2), 0.5) > PI - 0.5):
				horizontal_v = Vector3()
				input_x_vector.x = 0
				input_z_vector.z = 0
	
	if (self.is_on_floor()): is_moving_y = false
	target_rotation = 0
	is_moving_x = false
	is_moving_z = false
	_manage_cooldowns(delta)


func _custom_rotate():
	cameraArm.rotation_degrees.y = MAX_CAMERA_ROT_Y * camera_target_rotation_h
	cameraArm.rotation_degrees.x = INIT_CAMERA_ROT_X + (MAX_CAMERA_ROT_X * camera_target_rotation_v)
		
	self.rotate_y(target_rotation * 0.016)
		
	
func _shoot_main():
	if (mainCool != 0):
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 2000
	
	var space_state = get_world().direct_space_state
	var raycast_result = space_state.intersect_ray(from, to, [self], 1)

	if raycast_result:
		var shot :KinematicBody = mainProjectile.instance()
		parent.add_child(shot)
		shot.transform.origin = mainPos.global_transform.origin
		var final_velocity = raycast_result.position - shot.transform.origin
		
		if (current_forward.angle_to(final_velocity) > PI/2):
			shot.queue_free()
			return
			
		shot.velocity = final_velocity.normalized()
		mainCool = MAIN_COOL_MAX
	
	return


func _manage_cooldowns(increment):
	if (
		mainCool == 0
	):
		return
		
	mainCool -= increment
	mainCool = max(0, mainCool)



