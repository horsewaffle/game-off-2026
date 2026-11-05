extends Node3D

@export var cell_size: float = 1.0
@onready var floor_mesh: MeshInstance3D = $"../Floor"

var grid_size: Vector2i
var entity_positions: Dictionary = {}

func _ready() -> void:
	var floor_size: Vector2 = floor_mesh.mesh.size

	grid_size = Vector2i(
		floori(floor_size.x * floor_mesh.scale.x / cell_size),
		floori(floor_size.y * floor_mesh.scale.z / cell_size)
	)


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
	
	if not is_in_bounds(target_position) or target_position in entity_positions.values():
		return MoveResult.new(MoveResult.MoveEnum.FAIL, current_position)
		
	entity_positions[entity] = target_position
	return MoveResult.new(MoveResult.MoveEnum.SUCCESS, target_position)
