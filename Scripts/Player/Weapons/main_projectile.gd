extends KinematicBody


var velocity = Vector3()
var collision


func _physics_process(delta):
	collision = move_and_collide(velocity)
	if collision:
		queue_free()


