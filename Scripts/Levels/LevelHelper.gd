extends Node


onready var player = $Player
onready var camera = $Player/CameraArm/Camera
onready var hud = $Player/CameraArm/Camera/HUD
onready var enemiesParent = $EnemiesParent


func _ready():
	var enemies = enemiesParent.children
	camera.enemies = enemies
	
	for enemy in enemies:
		var visibility = enemy.get_child(0)
		enemy.camera = camera
		enemy.player = player
		enemy.hud = hud
		
		if (visibility):
			visibility.connect("screen_entered", camera, "lock_on_enemies", [enemy])
			visibility.connect("screen_exited", camera, "unlock_specific", [enemy])
	
	return
