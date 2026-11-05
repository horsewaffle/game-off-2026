extends CharacterBody3D

@onready var board = $"../Board"

# Signal for notifying the Board that the player has taken their turn
signal player_turn_taken

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
		
		if board_response.result != MoveResult.MoveEnum.SUCCESS:
			return
			
		var target_position: Vector2i = board_response.pos
		
		position = Vector3(
			target_position.x * board.cell_size,
			position.y,
			target_position.y * board.cell_size
		)
		
		can_take_action = false
		player_turn_taken.emit()

func _on_player_turn_readied():
	can_take_action = true
