extends Control


var followNode
var camera :Camera


onready var inner = $inner
onready var outer = $outer


func _ready():
	inner.visible = false
	outer.visible = false


func _physics_process(delta):
	if (followNode and camera):
		if followNode.get_child(0).is_on_screen():
			self.rect_position = camera.unproject_position(followNode.transform.origin)
