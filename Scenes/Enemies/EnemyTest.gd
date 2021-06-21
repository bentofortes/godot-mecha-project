extends KinematicBody


const LOCK_TIMER = 1.6
const HARD_LOCK_TIMER = 3.6


var lockHud
var hud
var camera
var player
var space_state


var lock_count = 0
var in_frame = false
var in_fixed = false
var in_hud = false
var obstructed = false
var soft_locked = false
var hard_locked = false
const states = {
	"non": 0,
	"soft_locking": 1,
	"soft_unlocking": 2,
	"soft_locked": 3,
	"hard_locking": 4,
	"hard_unlocking": 5,
	"hard_locked": 6,
}
var state = states.non
var prev_state = states.non


func _ready():
	space_state = get_world().direct_space_state


func _handle_timers(delta):
	if (!in_fixed and !in_hud) or obstructed:
		lock_count -= delta
		lock_count = max(lock_count, 0)
	
	elif (in_fixed and !in_hud) or (!in_fixed and in_hud):
		if (lock_count <= LOCK_TIMER):
			lock_count += delta
			lock_count = min(lock_count, LOCK_TIMER)
		else:
			lock_count -= delta
			lock_count = max(lock_count, LOCK_TIMER)
		
	elif (in_fixed and in_hud):
		lock_count += delta
		lock_count = min(lock_count, HARD_LOCK_TIMER)
		
	#state setting
	lock_count = stepify(lock_count, 0.001)
	
	if (!lockHud):
		state = states.non
	
	elif lock_count <= 0.1:
		state = states.non
		lockHud.inner.visible = false
		lockHud.outer.visible = false
		
	elif (lock_count > 0 and lock_count < LOCK_TIMER):
		lockHud.outer.visible = false
		lockHud.inner.visible = true
		if (state == states.non):
			state = states.soft_locking
			lockHud.inner.modulate.a = 0.5
		elif (state in [states.soft_locked, states.hard_unlocking]):
			state = states.soft_unlocking
			lockHud.inner.modulate.a = 1
			soft_locked = true
		
	elif lock_count == LOCK_TIMER:
		state = states.soft_locked
		lockHud.inner.visible = true
		lockHud.inner.modulate.a = 1
		soft_locked = true
		lockHud.outer.visible = false
		
	elif (lock_count > LOCK_TIMER and lock_count < HARD_LOCK_TIMER):
		lockHud.inner.visible = true
		lockHud.inner.modulate.a = 1
		soft_locked = true
		lockHud.outer.visible = true
		if (state in [states.soft_locked, states.soft_locking]):
			state = states.hard_locking
			lockHud.outer.modulate.a = 0.5
		elif (state == states.hard_locked):
			state = states.hard_unlocking
			lockHud.outer.modulate.a = 1
			hard_locked = true
			
		
	elif lock_count == HARD_LOCK_TIMER:
		state = states.hard_locked
		lockHud.inner.visible = true
		lockHud.outer.visible = true
		lockHud.inner.modulate.a = 1
		lockHud.outer.modulate.a = 1
		hard_locked = true
		soft_locked = true

	if (prev_state != state):
		player.soft_locked_list.erase(self)
		player.hard_locked_list.erase(self)

		if hard_locked:
			if !(self in player.hard_locked_list):
				player.hard_locked_list.append(self)

		elif soft_locked:
			if !(self in player.soft_locked_list):
				player.soft_locked_list.append(self)


func _check_regular_obstructions(state, from, to):
	obstructed = false
	var result = state.intersect_ray(from, to, [player, self], 1)
	if (result):
		if (result.collider):
			obstructed = true


func _check_fixed_box(state, from, to):
	var result = state.intersect_ray(from, to, [], 32)
	if (result):
		if (result.collider):
			in_fixed = true


func _check_hud_box():
	var pos = hud.get_child(0).rect_position
	var self_pos = camera.unproject_position(self.transform.origin)
	
	if (pos + Vector2(20,20)).distance_squared_to(self_pos) <= pow(85, 2):
		in_hud = true


func _physics_process(delta):
	if (!camera): return
#	if (!lockHud.inner or !lockHud.outer): return
	
	_handle_timers(delta)
		
	prev_state = state
	in_fixed = false
	in_hud = false
	obstructed = true
	soft_locked = false
	hard_locked = false
	
	if (!lockHud): return
		
#	var space_state = get_world().direct_space_state
	var from = self.global_transform.origin
	var to = camera.global_transform.origin
	
	if (from.distance_squared_to(to) > pow(70, 2)):
		return
	
	_check_regular_obstructions(space_state, from, to)
	_check_fixed_box(space_state, from, to)
	_check_hud_box()


func reset():
	lock_count = 0
	in_frame = false
	in_fixed = false
	in_hud = false
	obstructed = false
	soft_locked = false
	hard_locked = false
	state = 0
	if lockHud: lockHud.queue_free()
	


