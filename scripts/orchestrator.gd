class_name Orchestrator
extends Node3D

signal floor_readied
signal floor_finished
signal floor_changed(floor_number: int)
signal run_finished(floor_number: int)
signal turn_response(fulfilled: bool, packet: Dictionary)

const player_scene = preload("res://scenes/entities/player_character.tscn")
const enemy_scene = preload("res://scenes/entities/enemy.tscn")
const ui_scene = preload("res://scenes/ui/world_ui.tscn")
const floor_scene = preload("res://scenes/floor.tscn")
const stairs_scene = preload("res://scenes/stairs.tscn")
const spawn_safe_distance: int = 4
const neighbour_offsets = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]

var player: PlayerController
var player_camera: PlayerCamera
var current_floor: Node3D
var floor_number: int = 1
var tile_grid: Array
var rooms: Array
var grid_offset: Vector2i
var stairs_position: Vector2i
var live_entities: Dictionary[Entity, Vector2i]
var is_changing_floor: bool = false
var enemy_turn_running: bool = false
var run_ended: bool = false

var map_generator = MapGenerator.new()


func _ready():
	add_child(map_generator)
	instantiate_player_controller()
	instantiate_starter_deck()
	instantiate_player_camera()
	spawn_ui()
	instantiate_floor()


func instantiate_floor():
	is_changing_floor = true
	player.can_take_action = false
	var dungeon = map_generator.generate_map(40, "■", " ", 1, 20)
	tile_grid = dungeon["grid"]
	rooms = dungeon["rooms"]
	grid_offset = Vector2i(tile_grid[0].size() / 2 - 1, tile_grid.size() / 2 - 1)

	current_floor = floor_scene.instantiate()
	add_child(current_floor)
	place_player()

	var reachable_tiles = get_reachable_tiles(live_entities[player])
	instantiate_stairs(reachable_tiles)

	var grid_map: GridMap = current_floor.get_node("GridMap")
	grid_map.position += Vector3(0.5, 0, 0.5)
	grid_map.build(tile_grid)

	instantiate_enemies(reachable_tiles)
	is_changing_floor = false
	floor_changed.emit(floor_number)
	floor_readied.emit()
	player.adjacent_fightables = get_adjacent_fightables(player)
	player.take_turn()


func place_player():
	var spawn_room: Dictionary = rooms.pick_random()
	var spawn_position = map_generator.room_centre(spawn_room) - grid_offset
	player.position = Vector3(spawn_position.x, 0, spawn_position.y)
	live_entities[player] = spawn_position
	player.adjacent_fightables.clear()
	player_camera.snap_to_player()


func get_reachable_tiles(start: Vector2i) -> Dictionary[Vector2i, int]:
	var distances: Dictionary[Vector2i, int] = {start: 0}
	var pending: Array[Vector2i] = [start]
	var index: int = 0

	while index < pending.size():
		var position_2d = pending[index]
		index += 1
		for offset: Vector2i in neighbour_offsets:
			var next_position = position_2d + offset
			if not distances.has(next_position) and is_in_bounds(next_position):
				distances[next_position] = distances[position_2d] + 1
				pending.append(next_position)

	return distances


func instantiate_stairs(reachable_tiles: Dictionary[Vector2i, int]):
	var furthest_distance: int = -1
	for position_2d: Vector2i in reachable_tiles:
		if reachable_tiles[position_2d] > furthest_distance:
			stairs_position = position_2d
			furthest_distance = reachable_tiles[position_2d]

	var tile_position = stairs_position + grid_offset
	tile_grid[tile_position.y][tile_position.x] = ">"
	var stairs_instance = stairs_scene.instantiate()
	current_floor.add_child(stairs_instance)
	stairs_instance.position = Vector3(stairs_position.x, 0, stairs_position.y)


func instantiate_enemies(reachable_tiles: Dictionary[Vector2i, int]):
	var spawn_positions: Array[Vector2i] = []
	var player_position = live_entities[player]
	for position_2d: Vector2i in reachable_tiles:
		var distance = (position_2d - player_position).abs()
		if distance.x + distance.y < spawn_safe_distance:
			continue
		if position_2d == stairs_position or position_2d in live_entities.values():
			continue
		spawn_positions.append(position_2d)

	spawn_positions.shuffle()
	var enemy_count = mini(FloorDifficulty.get_enemy_count(floor_number), spawn_positions.size())
	for index in range(enemy_count):
		instantiate_enemy(spawn_positions[index])


func instantiate_enemy(pos: Vector2i):
	var new_enemy: Enemy = enemy_scene.instantiate()
	new_enemy.floor_number = floor_number
	new_enemy.position = Vector3(pos.x, 0, pos.y)
	new_enemy.turn_requested.connect(_on_turn_requested)
	new_enemy.xp_awarded.connect(player.gain_xp)
	live_entities[new_enemy] = pos
	current_floor.add_child(new_enemy)


func instantiate_player_controller():
	player = player_scene.instantiate()
	player.init_stats()
	add_child(player)
	player.turn_requested.connect(_on_turn_requested)
	player.enemy_turn_triggered.connect(_on_enemy_turn_triggered)
	player.fightable.dead.connect(_on_player_death)


func instantiate_starter_deck():
	var card = Card.new("bsr1", "Bitshift Right 1", "test", CardFunctions.bsr1)
	player.deck.add_to_roster(card)
	card = Card.new("bsr2", "Bitshift Right 2", "test", CardFunctions.bsr2)
	player.deck.add_to_roster(card)
	card = Card.new("bm81", "Bitmask 8 =1", "test", CardFunctions.bm81)
	player.deck.add_to_roster(card)
	player.deck.reset_deck()


func instantiate_player_camera():
	player_camera = PlayerCamera.new()
	add_child(player_camera)
	player_camera.init_player_camera(player)


func spawn_ui():
	var ui_instance = ui_scene.instantiate()
	add_child(ui_instance)
	ui_instance.init_stats(player)
	ui_instance.ui_attack_prepared.connect(_on_ui_attack_prepared)
	floor_changed.connect(ui_instance.update_floor)
	floor_finished.connect(ui_instance.clear_floor_targets)
	run_finished.connect(ui_instance.on_run_finished)


func advance_floor():
	if is_changing_floor or run_ended or enemy_turn_running:
		return

	is_changing_floor = true
	player.can_take_action = false
	floor_finished.emit()
	live_entities.clear()
	remove_child(current_floor)
	current_floor.queue_free()
	floor_number += 1
	instantiate_floor()


func _on_enemy_turn_triggered():
	if is_changing_floor or run_ended or enemy_turn_running:
		return

	enemy_turn_running = true
	for entity: Entity in get_tree().get_nodes_in_group("turn_listener"):
		if run_ended:
			break
		if not live_entities.has(entity) or entity.fightable == null:
			continue
		entity.adjacent_fightables = get_adjacent_fightables(entity)
		await entity.take_turn()
		await get_tree().create_timer(0.1).timeout

	enemy_turn_running = false
	if not run_ended:
		player.adjacent_fightables = get_adjacent_fightables(player)
		player.take_turn()


func _on_ui_attack_prepared(target_pos: Vector2i):
	if is_changing_floor or run_ended or not player.can_take_action:
		return

	var distance = (target_pos - live_entities[player]).abs()
	if distance.x + distance.y != 1:
		return

	if target_pos in live_entities.values():
		var target_ent: Entity = live_entities.find_key(target_pos)
		if target_ent.fightable != null:
			player.can_take_action = false
			player.attack(target_ent)
			player.end_turn()


func _on_turn_requested(entity: Entity, pos: Vector2i, action: String):
	if is_changing_floor or run_ended or not live_entities.has(entity):
		return
	if action != "move" or not entity.can_take_action:
		return
	if entity == player:
		player.can_take_action = false
	elif not enemy_turn_running:
		return

	var result = process_move(entity, pos)
	if result.result == MoveResult.MoveEnum.SUCCESS:
		await entity.move(pos)
	else:
		await entity.handle_turn_response(result, pos, result.occupant)

	if entity == player and live_entities[player] == stairs_position:
		advance_floor()
		return
	entity.end_turn()


func process_move(entity: Entity, target: Vector2i) -> MoveResult:
	if not live_entities.has(entity):
		return MoveResult.new(MoveResult.MoveEnum.FAIL)

	var current_position = live_entities[entity]
	var distance = (target - current_position).abs()
	if distance.x + distance.y != 1 or not is_in_bounds(target):
		return MoveResult.new(MoveResult.MoveEnum.FAIL, current_position)
	if entity != player and target == stairs_position:
		return MoveResult.new(MoveResult.MoveEnum.FAIL, current_position)

	if target in live_entities.values():
		var occupant: Entity = live_entities.find_key(target)
		if occupant.walkable:
			live_entities.erase(occupant)
			live_entities[entity] = target
			occupant.queue_free()
			return MoveResult.new(MoveResult.MoveEnum.INTERACT_AND_MOVE, target, occupant)
		return MoveResult.new(MoveResult.MoveEnum.INTERACT, current_position, occupant)

	live_entities[entity] = target
	return MoveResult.new(MoveResult.MoveEnum.SUCCESS, target)


func is_in_bounds(grid_position: Vector2i) -> bool:
	var offset_position = grid_position + grid_offset
	if offset_position.x < 0 or offset_position.y < 0:
		return false
	if offset_position.y >= tile_grid.size():
		return false
	if offset_position.x >= tile_grid[offset_position.y].size():
		return false
	return tile_grid[offset_position.y][offset_position.x] in [" ", ">"]


func get_adjacent_fightables(entity: Entity) -> Array[Entity]:
	var adj_fightables_list: Array[Entity] = []
	if not live_entities.has(entity):
		return adj_fightables_list

	var entity_pos = live_entities[entity]
	for offset: Vector2i in neighbour_offsets:
		var query_pos = entity_pos + offset
		if query_pos in live_entities.values():
			var query_entity: Entity = live_entities.find_key(query_pos)
			if query_entity.fightable == null or query_entity.fightable.death_check():
				continue
			if entity is PlayerController or query_entity is PlayerController:
				adj_fightables_list.append(query_entity)
	return adj_fightables_list


func _on_player_death():
	if run_ended:
		return
	run_ended = true
	player.can_take_action = false
	run_finished.emit(floor_number)
