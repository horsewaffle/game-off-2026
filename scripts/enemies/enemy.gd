class_name Enemy
extends Entity

@onready var board = $"../Board"

func _ready() -> void:
	fightable = Fightable.new(100, 20)

func take_turn():

	var offset = [Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0), Vector2i(0,-1)].pick_random()
	
	var board_response = board.process_move(self, offset)

	if board_response.result == MoveResult.MoveEnum.SUCCESS:
			var target_position: Vector2i = board_response.pos
			
			position = Vector3(
				target_position.x * board.cell_size,
				position.y,
				target_position.y * board.cell_size
			)
