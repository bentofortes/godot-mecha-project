extends CollisionShape


var velocity = Vector3(0, 0, 20)


func _ready():
	connect("body_entered", self, "_end")
	connect("body_shape_entered", self, "_end")


func _physics_process(delta):
#	self.transform.origin += velocity * delta
	translate_object_local(velocity * delta)


func _end():
	print("a")
	self.queue_free()


