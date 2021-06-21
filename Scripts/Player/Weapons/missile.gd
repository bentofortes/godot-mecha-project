extends KinematicBody


onready var shape = $CollisionShape
onready var position = $Position3D
onready var explosion = $Explosion
var target :Node


var velocity = Vector3()
var direction = Vector3()
var destiny = Vector3()
var steer = Vector3()

#
#func _ready():
#	connect("body_shape_entered", self, "_explode")
#	connect("body_entered", self, "_explode")
#	connect("area_shape_entered", self, "_explode")
#	connect("area_entered", self, "_explode")


func _physics_process(delta):
	if !target: return
	
	direction = (position.global_transform.origin - shape.global_transform.origin).normalized()
	destiny = (target.global_transform.origin - self.global_transform.origin).normalized()
	steer = (destiny - direction).normalized()
	
	velocity = ((direction * 100) + (steer * 2.5)).normalized() * delta
	
	self.look_at(self.global_transform.origin + velocity, Vector3.UP)
	var collision =  move_and_collide(velocity * 18)
	if collision: _explode()
#	self.look_at(self.global_transform.origin + velocity, Vector3.UP)
	
func _explode():
	print("explode")
#	explosion.visible = true
#	self.set_physics_process(false)
	self.queue_free()
