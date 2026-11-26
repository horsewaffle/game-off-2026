extends GridMap

func build(grid: Array) -> void:
	var offset_x: int = grid[0].size() / 2
	var offset_y: int = grid.size() / 2

	for y in range(grid.size()):
		for x in range(grid[y].size()):
			var tile = grid[y][x]

			match tile:
				" ":
					set_cell_item(
						Vector3i(x - offset_x, 0, y - offset_y), 0)
				"■":
					var air_neighbours = get_neighbouring_air(grid, x, y)
					var orientation: int = 0
					var type: int = 4
					#top wall and left wall correct, right wall and bottom wall wrong
					match air_neighbours:
						"0000":
							# full block
							orientation = 0
							type = 3
						"1000":
							# left wall correct at 0
							orientation = 0
							type = 1
						"0100":
							# top wall correct at 22
							orientation = 22
							type = 1
						"0010":
							# right wall correct at 10
							orientation = 10
							type = 1
						"0001":
							# bottom wall correct at 16
							orientation = 16
							type = 1
						"1100":
							# br correct at 0
							orientation = 0
							type = 2
						"0110":
							# bl correct at 22
							orientation = 22
							type = 2
						"0011":
							
							orientation = 10
							type = 2
						"1001":
							
							orientation = 16
							type = 2

					# 16 is north, 0 east, 22 south, 10 west
					set_cell_item(
						Vector3i(x - offset_x, 0, y - offset_y), type,  orientation)
						
func get_neighbouring_air(grid: Array, x: int, y: int) -> String:
	# NESW
	var out = "0000"
	
	# I deeply wonder if there's a better way to do this.
	if x >= grid[0].size() - 1:
		out[0] = "0"
	elif grid[y][x + 1] == " ":
		out[0] = "1"
		
	if x <= 0:
		out[2] = "0"
	elif grid[y][x - 1] == " ":
		out[2] = "1"
		
	if  y >= grid.size() - 1:
		out[1] = "0"
	elif grid[y + 1][x] == " ":
		out[1] = "1"
		
	if y <= 0:
		out[3] = "0"
	elif grid[y - 1][x] == " ":
		out[3] = "1"
	
	return out
	
