extends KinematicBody


const LOCK_TIMER = 1.6
const FULL_LOCK_TIMER = 3.6


var lockHud
var hud
var camera
var player


var lock_count = 0
var in_frame = false
var in_fixed = false
var in_hud = false
var obstructed = false
var half_locked = false
var full_locked = false
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


func _handle_timers(delta):
	if (!in_fixed and !in_hud) or obstructed:
		lock_count -= delta * 2.0/3
		lock_count = max(lock_count, 0)
	
	elif (in_fixed and !in_hud) or (!in_fixed and in_hud):
		lock_count += delta
		lock_count = min(lock_count, LOCK_TIMER)
		
	elif (in_fixed and in_hud):
		lock_count += delta
		lock_count = min(lock_count, FULL_LOCK_TIMER)
		
	#state setting
	lock_count = stepify(lock_count, 0.001)
	prev_state = state
	
	if lock_count == 0:
		state = states.non
		lockHud.inner.visible = false
		lockHud.outer.visible = false
		
	elif (lock_count > 0 and lock_count < LOCK_TIMER):
		lockHud.outer.visible = false
		lockHud.inner.visible = true
		if (state == states.non):
			state = states.soft_locking
			lockHud.inner.modulate.a = 0.5
		elif (state == states.soft_locked):
			state = states.soft_unlocking
			lockHud.inner.modulate.a = 1
		
	elif lock_count == LOCK_TIMER:
		state = states.soft_locked
		lockHud.inner.visible = true
		lockHud.inner.modulate.a = 1
		lockHud.outer.visible = false
		
	elif (lock_count > LOCK_TIMER and lock_count < FULL_LOCK_TIMER):
		if (state == states.soft_locked):
			lockHud.outer.visible = true
			state = states.hard_locking
			lockHud.outer.modulate.a = 0.5
		elif (state == states.hard_locked):
			state = states.hard_unlocking
			lockHud.outer.modulate.a = 1
		
	elif lock_count == FULL_LOCK_TIMER:
		state = states.hard_locked
		lockHud.inner.visible = true
		lockHud.outer.visible = true
		lockHud.outer.modulate.a = 1
#
#	if (prev_state != state):
#		print(states.keys()[prev_state], " -> ", states.keys()[state], lock_count)


func _check_regular_obstructions(state, from, to):
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
	if (!camera or !lockHud): return
	if (!lockHud.inner or !lockHud.outer): return
		
	in_fixed = false
	in_hud = false
		
	var space_state = get_world().direct_space_state
	var from = self.global_transform.origin
	var to = camera.global_transform.origin
	
	_check_regular_obstructions(space_state, from, to)
	_check_fixed_box(space_state, from, to)
	_check_hud_box()
	
	_handle_timers(delta)

func reset():
	lock_count = 0
	in_frame = false
	in_fixed = false
	in_hud = false
	obstructed = false
	half_locked = false
	full_locked = false
	state = 0

