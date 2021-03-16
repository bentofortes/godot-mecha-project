extends Camera
class_name CustomCamera


const SHRINK = 3.0
const SCREEN_V = 1080/SHRINK
const SCREEN_H = 1920/SHRINK
const DRAG_STOP = 100/SHRINK
const DRAG_START = 150/SHRINK
const MOUSE_LIMIT_R = 1720/SHRINK
const MOUSE_LIMIT_L = 200/SHRINK
const MOUSE_LIMIT_U = 100/SHRINK
const MOUSE_LIMIT_D = 980/SHRINK
const BOX_LIMIT_R = 1470/SHRINK
const BOX_LIMIT_L = 450/SHRINK
const BOX_LIMIT_U = 350/SHRINK
const BOX_LIMIT_D = 730/SHRINK


var lockHud = preload("res://Scenes/LockHUD.tscn")

onready var parent = self.get_parent().get_parent()
onready var HUD = self.get_child(0)
onready var crosshair = HUD.get_child(1)
onready var box = HUD.get_child(0)


var mouse_pos
var box_target


var enemies


func _ready():
	self.set_physics_process(false)
	
	mouse_pos = get_viewport().get_mouse_position()
	box.set_position(Vector2(SCREEN_H/2.0, SCREEN_V/2.0))
	box_target = Vector2(SCREEN_H/2.0, SCREEN_V/2.0)


func place_crosshair():
#	var mouse_pos = get_viewport().get_mouse_position()
#	var from = self.project_ray_origin(mouse_pos)
#	var to = from + self.project_ray_normal(mouse_pos) * 3000
#
#	var collision_mask = 16
#	var result = space_state.intersect_ray(from, to, [], collision_mask)
#	var local_pos = HUD.to_local(result.position)
#	crosshair.transform.origin.y = local_pos.y
#	crosshair.transform.origin.x = local_pos.x
#	print(result["position"])
	
	mouse_pos = get_viewport().get_mouse_position()
	
	if (mouse_pos.x <= MOUSE_LIMIT_L):
		mouse_pos.x = MOUSE_LIMIT_L
	elif (mouse_pos.x >= MOUSE_LIMIT_R):
		mouse_pos.x = MOUSE_LIMIT_R
		
	if (mouse_pos.y <= MOUSE_LIMIT_U):
		mouse_pos.y = MOUSE_LIMIT_U
	elif (mouse_pos.y >= MOUSE_LIMIT_D):
		mouse_pos.y = MOUSE_LIMIT_D
		
	if (mouse_pos.distance_squared_to(box.rect_position) > pow(DRAG_START, 2)):
		box_target = mouse_pos
		self.set_physics_process(true)


func lock_on_enemies(enemy: Node):
	if enemy.get_child(0).is_on_screen() and !enemy.in_frame:
		var instance = lockHud.instance()
		instance.rect_position = (self.unproject_position(enemy.transform.origin))
		instance.camera = self
		instance.followNode = enemy
		enemy.in_frame = true
		enemy.lockHud = instance
		HUD.add_child(instance)


func unlock_specific(enemy: Node):
	if !enemy.get_child(0).is_on_screen() and enemy.in_frame:
		if (enemy.lockHud):
#			pass
#			enemy.lockHud = null
			enemy.reset()


func _physics_process(delta):
	var current_pos = box.rect_position
	if (box_target.distance_squared_to(current_pos) <= pow(DRAG_STOP, 2)):
		box_target = current_pos
		return

	else:
		var direction = (box_target - current_pos).normalized()
		var dest = current_pos + (direction * 4)
		
		#Horizontal limits
		if (dest.x < BOX_LIMIT_L):
			direction = Vector2(0, direction.y)
			
			if (direction.length_squared() <= 0.6):
				set_physics_process(false)
				return
				
			dest = current_pos + (direction.normalized() * 4)
			dest.x = BOX_LIMIT_L
			
		elif (dest.x > BOX_LIMIT_R):
			direction = Vector2(0, direction.y)
			
			if (direction.length_squared() <= 0.6):
				set_physics_process(false)
				return
				
			dest = current_pos + (direction.normalized() * 4)
			dest.x = BOX_LIMIT_R
			
		#Vertical limits
		if (dest.y < BOX_LIMIT_U):
			direction = Vector2(direction.x, 0)
			
			if (direction.length_squared() <= 0.6):
				set_physics_process(false)
				return
				
			dest = current_pos + (direction.normalized() * 4)
			dest.y = BOX_LIMIT_U
			
		elif (dest.y > BOX_LIMIT_D):
			direction = Vector2(direction.x, 0)
			
			if (direction.length_squared() <= 0.6):
				set_physics_process(false)
				return
				
			dest = current_pos + (direction.normalized() * 4)
			dest.y = BOX_LIMIT_D
			
		box.set_position(dest)
		
	
	
