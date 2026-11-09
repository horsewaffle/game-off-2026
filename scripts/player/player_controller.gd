extends CharacterBody3D

class_name PlayerController

@onready var board = $"../Board"

# Signal for notifying the Board that the player has taken their turn
signal player_turn_taken

# Can the player provide blocking input?
var can_take_action = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (board != null):
		board.player_turn_readied.connect(_on_player_turn_readied)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _input(_event) -> void:
	var board_response = null
	
	# Logic for actions that are considered a turn - prevent user from getting
	# more than one action per enemy turn by disabling input until all enemies
	# are happy with their turn.
	#
	# ... this is just movement for now.
	if (can_take_action):
		
		# I wonder what would happen if you pressed two actions at the EXACT
		# same time?
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
			
		
		can_take_action = false

		# Minimum turn time so players don't accidentally spam
		await get_tree().create_timer(0.3).timeout
		
		player_turn_taken.emit()

func _on_player_turn_readied():
	if (is_adjacent_to_fightable()):
		print("Adjacent to fightable, trigger combat UI")
	can_take_action = true

func is_adjacent_to_fightable() -> bool:
	# Intentional loss of precision to snap to grid
	@warning_ignore("narrowing_conversion")
	var grid_pos = Vector2i(position.x, position.z)

	for offset in [Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0), Vector2i(0,-1)]:
		var check_pos = grid_pos + offset
		var queryResult = board.query_board(check_pos)
		if (queryResult != null and queryResult is Entity and queryResult.fightable != null):
			return true
			
	return false
