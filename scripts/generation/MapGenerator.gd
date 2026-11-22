class_name MapGenerator
extends Node

@export var grid_size: int = 40
@export var wall: String = "■"
@export var tilefloor: String = " "
@export var padding: int = 1
@export var timeout: int = 20


func _ready() -> void:
	var _map_data: Dictionary = generate_map(
		grid_size, wall, tilefloor, padding, timeout
	)




func display_grid(grid: Array) -> void:
	for row in grid:
		print(" ".join(PackedStringArray(row)))



func rooms_overlap(a: Dictionary, b: Dictionary, room_padding: int) -> bool:
	return not (
		a["x"] + a["width"] + room_padding <= b["x"] or
		b["x"] + b["width"] + room_padding <= a["x"] or
		a["y"] + a["length"] + room_padding <= b["y"] or
		b["y"] + b["length"] + room_padding <= a["y"]
	)


func room_centre(room: Dictionary) -> Vector2i:
	var x: int = room["x"] + room["width"] / 2
	var y: int = room["y"] + room["length"] / 2

	return Vector2i(x, y)


func carve_corridor(grid: Array, start: Vector2i, end: Vector2i, floor_tile: String) -> void:
	var x1: int = start.x
	var y1: int = start.y
	var x2: int = end.x
	var y2: int = end.y

	for x in range(mini(x1, x2), maxi(x1, x2) + 1):
		grid[y1][x] = floor_tile

	for y in range(mini(y1, y2), maxi(y1, y2) + 1):
		grid[y][x2] = floor_tile


func generate_rooms(
	grid: Array,
	rooms: Array,
	max_room_size: int,
	attempts: int,
	room_padding: int,
	floor_tile: String
) -> void:

	var size: int = grid.size()

	for _i in range(attempts):
		var room_length: int = randi_range(2, max_room_size)
		var room_width: int = randi_range(2, max_room_size)

		# Top-left coordinate
		var max_x: int = size - room_width - room_padding
		var max_y: int = size - room_length - room_padding

		if max_x < room_padding or max_y < room_padding:
			continue

		var room_x: int = randi_range(room_padding, max_x)
		var room_y: int = randi_range(room_padding, max_y)

		var proposed_room: Dictionary = {
			"x": room_x,
			"y": room_y,
			"length": room_length,
			"width": room_width
		}

		var overlaps: bool = false

		for existing_room in rooms:
			if rooms_overlap(existing_room, proposed_room, room_padding):
				overlaps = true
				break

		if overlaps:
			continue

		for y in range(room_y, room_y + room_length):
			for x in range(room_x, room_x + room_width):
				grid[y][x] = floor_tile

		rooms.append(proposed_room)


func generate_map(
	size: int,
	wall_tile: String,
	floor_tile: String,
	room_padding: int,
	attempts: int
) -> Dictionary:

	var grid: Array = []
	var rooms: Array = []

	for y in range(size):
		var row: Array = []
		for x in range(size):
			row.append(wall_tile)
		grid.append(row)

	var max_room_size: int = size / 3

	generate_rooms(grid, rooms, max_room_size, attempts, room_padding, floor_tile)

	max_room_size = maxi(4, max_room_size / 4)

	generate_rooms(grid, rooms, max_room_size, attempts, room_padding, floor_tile)

	for i in range(1, rooms.size()):
		var start: Vector2i = room_centre(rooms[i - 1])
		var end: Vector2i = room_centre(rooms[i])

		carve_corridor(grid, start, end, floor_tile)

	return {
		"grid": grid,
		"rooms": rooms
	}
