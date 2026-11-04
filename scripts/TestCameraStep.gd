extends Node


func _input(_event):
	if Input.is_action_just_pressed("MOVE_UP"):
		self.position.z -= 1
	if Input.is_action_just_pressed("MOVE_DOWN"):
		self.position.z += 1
	if Input.is_action_just_pressed("MOVE_LEFT"):
		self.position.x -= 1
	if Input.is_action_just_pressed("MOVE_RIGHT"):
		self.position.x += 1
