extends Node3D

@export var cell_size: float = 1.0
@onready var floor_mesh: MeshInstance3D = $"../Floor"
@onready var player: CharacterBody3D = $"../PlayerCharacter"

# Signal for notifying the player controller their turn is ready
signal player_turn_readied

var grid_size: Vector2i
var entity_positions: Dictionary = {}

func _ready() -> void:
	var floor_size: Vector2 = floor_mesh.mesh.size
	
	grid_size = Vector2i(
		floori(floor_size.x * floor_mesh.scale.x / cell_size),
		floori(floor_size.y * floor_mesh.scale.z / cell_size)
	)
	if (player != null):
		player.player_turn_taken.connect(_on_player_turn_taken)
		player_turn_readied.emit()

# == [[ UTIL FUNCTIONS ]] ==

func is_in_bounds(grid_position: Vector2i) -> bool:
	var min_x: int = -floori(grid_size.x / 2.0)
	var min_y: int = -floori(grid_size.y / 2.0)
	
	return (
		grid_position.x >= min_x
		and grid_position.x <= min_x + grid_size.x
		and grid_position.y >= min_y
		and grid_position.y <= min_y + grid_size.y
	)


func is_invalid_direction_vector(direction: Vector2i) -> bool:
	return abs(direction.x) + abs(direction.y) != 1

# == [[ ENTITY LOGIC ]] ==

func register_entity(entity: Node3D) -> bool:
	if entity not in entity_positions:
		var grid_position: Vector2i = Vector2i(
			roundi(entity.position.x / cell_size),
			roundi(entity.position.z / cell_size)
		)
		
		if grid_position not in entity_positions.values() and is_in_bounds(grid_position):
			entity_positions[entity] = grid_position
			return true
	
	return false


func process_move(entity: Node3D, direction: Vector2i) -> MoveResult:
	if entity not in entity_positions:
		return MoveResult.new(MoveResult.MoveEnum.FAIL, null)
		
	if is_invalid_direction_vector(direction):
		return MoveResult.new(MoveResult.MoveEnum.FAIL, entity_positions[entity])
	
	var current_position: Vector2i = entity_positions[entity]
	var target_position: Vector2i = current_position + direction
	
	if not is_in_bounds(target_position):
		return MoveResult.new(MoveResult.MoveEnum.FAIL, current_position)
	
	if target_position in entity_positions.values():
		var occupant = entity_positions.find_key(target_position)
		
		if occupant.name == "PlayerCharacter":
			return MoveResult.new(MoveResult.MoveEnum.INTERACT, current_position, occupant)
		elif occupant is Enemy:
			return MoveResult.new(MoveResult.MoveEnum.INTERACT, current_position, occupant)
		
	
	entity_positions[entity] = target_position
	return MoveResult.new(MoveResult.MoveEnum.SUCCESS, target_position)

# Take a position and return a reference to the entity at that position (or null) without registering a move.
func query_board(query_pos: Vector2i) -> Node3D:
	if query_pos in entity_positions.values():
		return entity_positions.find_key(query_pos)
	else:
		return null


# ==[[ TURN LOGIC ]] ==

# Turns will be handled by using groups to call an abstract "take_turn" function
# on all in the "turn_listener" group. The player should NOT be part of this
# group! We will take input from the player as a turn, which will emit the
# "player_turn_taken" signal, disable player input, emit to all "turn_listener"
# entities causing the CPU turn, and once that call has resolved, pass control
# back to the player.

# Called when the player is done with their turn (usually, after movement)
func _on_player_turn_taken():
	process_entity_turn()
	

# Call the take_turn function of all entities waiting on a turn.
func process_entity_turn() -> void:
	get_tree().call_group("turn_listener", "take_turn")

	# Minimum turn time so players can process CPU turn
	await get_tree().create_timer(0.3).timeout

	player_turn_readied.emit()
