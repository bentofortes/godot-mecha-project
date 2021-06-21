extends Node


onready var children = self.get_children()


var targets = []


func update_targets():
	for child in children:
		child.target = targets[0]

