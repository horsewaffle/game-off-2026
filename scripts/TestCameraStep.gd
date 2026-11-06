extends CharacterBody3D

@onready var board = $"../Board"

func _input(_event) -> void:
	var board_response = null
	
	if Input.is_action_just_pressed("MOVE_UP"):
		board_response = board.process_move(self, Vector2i(0, -1))
	if Input.is_action_just_pressed("MOVE_DOWN"):
		board_response = board.process_move(self, Vector2i(0, 1))
	if Input.is_action_just_pressed("MOVE_LEFT"):
		board_response = board.process_move(self, Vector2i(-1, 0))
	if Input.is_action_just_pressed("MOVE_RIGHT"):
		board_response = board.process_move(self, Vector2i(1, 0))
		
	if board_response == null:
		return
	
	if board_response.result == MoveResult.MoveEnum.SUCCESS:
		var target_position: Vector2i = board_response.pos
		
		position = Vector3(
			target_position.x * board.cell_size,
			position.y,
			target_position.y * board.cell_size
		)
	
	elif board_response.result == MoveResult.MoveEnum.INTERACT:
		print("am finna scrap ", board_response.occupant)
	
