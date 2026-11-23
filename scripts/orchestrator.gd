class_name Orchestrator
extends Node3D

# The Orchestrator should be responsible for the game state. This includes:
# - Instantiating the Floor that the player is on
# - Spawning Entities onto that floor - including Enemies
# - Passing game events around to their recipients - prompts to take their turn, attacks, etc.
# The logic for these events can be delegated to child scripts, but the calls to actually perform them
# should pass through the Orchestrator at least once.

# Also, connect children to the Orchestrator using signals/groups/etc not direct code!
# We don't know where each one will be in the Scene, so hardcoding paths is a recipe for disaster,
# especially for one-to-many relationships with Nodes that may not persist, like Orchestrator:Enemy

# ||=========================|| #
# ||         SIGNALS         || #
# ||=========================|| #

# Emitted when a Floor is ready for gameplay, for the turn loop to start
signal floor_readied

# Emitted when a Floor is finished, to pause turn loop and begin cleanup/start new Floor instantiation
signal floor_finished

# Emitted in response to a request from an Entity
signal turn_response(fulfilled: bool, packet: Dictionary)

# ||=========================|| #
# ||  GAME SPACE VARIABLES   || #
# ||=========================|| #

# Reference to the player controller. Should be empty until the Orchestrator instantiates the player
const player_scene = preload("res://scenes/entities/player_character.tscn")
var player

const enemy_scene = preload("res://scenes/entities/enemy.tscn")

const ui_scene = preload("res://scenes/ui/world_ui.tscn")

const floor_scene = preload("res://scenes/floor.tscn")

# Reference to the current floor the game is on.
var current_floor: Node3D

# Grid of floor/wall tiles used to determine if a tile is traversible.
var tile_grid: Array
# References to all rooms in the generated floor, primarily for spawning player.
var rooms: Array

# Reference to all currently instantiated Entities and positions - this includes the PlayerController!
var live_entities: Dictionary[Entity, Vector2i]

# Reference to the map generating algorithm
var map_generator = MapGenerator.new()


# ||=========================|| #
# || INSTANTIATION FUNCTIONS || #
# ||=========================|| #

# Wrapper function for instantiating a Floor when the player moves to it. This should:
# - Generate the Floor geometry
# - Spawn Entities into the Floor
# - Move the generated Floor into the Game scene
# - Spawn the PlayerController onto the Floor
# - Emit a floor_readied signal when done, to signal beginning of gameplay
func instantiate_floor():
	var dungeon = map_generator.generate_map(40, "■", " ", 1, 20)
	var floor_instance = floor_scene.instantiate()
	tile_grid = dungeon["grid"]
	rooms = dungeon["rooms"]
	
	add_child(floor_instance)
	floor_instance.get_node("GridMap").build(tile_grid)
	
	var grid_map: GridMap = floor_instance.get_node("GridMap")
	
	# Offset the actual map such that the nodes in the grid are in the middle of
	# their corresponding tiles.
	grid_map.position += Vector3(0.5, 0, 0.5)
	
	floor_readied.emit()

# Wrapper function for spawning an Entity into the current Floor.
func instantiate_entity():
	pass
	
func instantiate_enemy(pos: Vector2i):
	var new_enemy: Entity = enemy_scene.instantiate()
	add_child(new_enemy)
	live_entities[new_enemy] = pos
	new_enemy.position = Vector3i(pos.x, 0, pos.y)
	new_enemy.turn_requested.connect(_on_turn_requested)

# Wrapper function for instantiating the PlayerController
func instantiate_player_controller():
	player = player_scene.instantiate()
	player.init_stats()
	add_child(player)
	player.turn_requested.connect(_on_turn_requested)
	player.enemy_turn_triggered.connect(_on_enemy_turn_triggered)
	
	# Spawn player in a random room
	var spawn_room = rooms.pick_random()
	print("Spawning player at room: ", spawn_room)
	var spawn_x = spawn_room["x"] - 19
	var spawn_y = spawn_room["y"] - 19
	
	player.position = Vector3(spawn_x, 0, spawn_y)
	live_entities[player] = Vector2i(spawn_x,spawn_y)

# Helper function for listening to UI signals
func spawn_ui():
	var ui_instance = ui_scene.instantiate()
	add_child(ui_instance)
	ui_instance.init_stats(player)
	ui_instance.ui_attack_prepared.connect(_on_ui_attack_prepared)


# Currently, the Orchestrator spawns in a Floor when added to the scene for testing. Eventually,
# this should stop being the case - the Orchestrator will be triggered by the game starting
# from the menu.
func _ready():
	
	print_debug("[Orchestrator] Beginning floor instantiation...")
	instantiate_floor()
	print_debug("[Orchestrator] Floor instantiation finished.")
	
	print_debug("[Orchestrator] Spawning in PlayerController...")
	instantiate_player_controller()
	print_debug("[Orchestrator] PlayerController instantiation finished.")
	
	print_debug("[Orchestrator] Spawning UI...")
	spawn_ui()
	print_debug("[Orchestrator] UI spawned.")
	
	print_debug("[Orchestrator] Spawning one test Enemy...")
	instantiate_enemy(Vector2i(1, 1))
	print_debug("[Orchestrator] One enemy spawned.")
	floor_readied.emit()
	
	player.take_turn()
	
func _on_enemy_turn_triggered():
	
	# Let all non-player entities take their turn...
	for entity: Entity in get_tree().get_nodes_in_group("turn_listener"):
		entity.adjacent_fightables = get_adjacent_fightables(entity)
		await entity.take_turn()
		await get_tree().create_timer(0.3).timeout
	
	# After entities are done taking their turn, pass turn back to player.
	player.adjacent_fightables = get_adjacent_fightables(player)
	player.take_turn()

func _on_ui_attack_prepared(target_pos: Vector2i):
	if target_pos in live_entities.values():
			var target_ent = live_entities.find_key(target_pos)
			if (target_ent.fightable != null):
				player.attack(target_ent)
				player.end_turn()


func _on_turn_requested(entity: Entity, pos: Vector2i, action: String):
	var result: MoveResult
	match(action):
		"move":
			result = process_move(entity, pos)
			if result.result == MoveResult.MoveEnum.SUCCESS:
				entity.move(pos)
				entity.end_turn()
			else:
				entity.handle_turn_response(result, pos, result.occupant)
				entity.end_turn()
			
			
func process_move(entity: Entity, target: Vector2i) -> MoveResult:
	
	var current_position = live_entities[entity]
	if not is_in_bounds(target):
		return MoveResult.new(MoveResult.MoveEnum.FAIL, current_position)
	
	if target in live_entities.values():
		var occupant = live_entities.find_key(target)
		
		return MoveResult.new(MoveResult.MoveEnum.INTERACT, current_position, occupant)
		
	live_entities[entity] = target
	return MoveResult.new(MoveResult.MoveEnum.SUCCESS, target)

func is_in_bounds(grid_position: Vector2i) -> bool:
	# Grid array counts from 0->40, whereas co-ords count from -20->20
	var offset_position = grid_position + Vector2i(19, 19)
	if (
		tile_grid.size() <= offset_position.y 
		or tile_grid[offset_position.y].size() <= offset_position.x
	):
		return false
	return (
		tile_grid[offset_position.y][offset_position.x] == " "
	)

func get_adjacent_fightables(entity: Entity) -> Array[Entity]:
	var adj_fightables_list: Array[Entity] = []
	var entity_pos = live_entities[entity]
	for offset in [Vector2i(1,0), Vector2i(0,1), Vector2i(-1,0), Vector2i(0,-1)]:
		var query_pos = entity_pos + offset
		if query_pos in live_entities.values():
			var query_entity = live_entities.find_key(query_pos)
			if (entity is PlayerController and query_entity.fightable != null):
				adj_fightables_list.append(query_entity) 
			elif query_entity is PlayerController:
				adj_fightables_list.append(query_entity)
	return adj_fightables_list
