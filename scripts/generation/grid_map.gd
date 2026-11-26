extends GridMap

func build(grid: Array) -> void:
	var offset_x: int = grid[0].size() / 2
	var offset_y: int = grid.size() / 2

	for y in range(grid.size()):
		for x in range(grid[y].size()):
			var tile = grid[y][x]

			match tile:
				" ", ">":
					set_cell_item(
						Vector3i(x - offset_x, 0, y - offset_y), 0)
				"■":
					set_cell_item(
						Vector3i(x - offset_x, 0, y - offset_y), 1)
