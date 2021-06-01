extends Node2D

class_name Level

onready var npc = $NPCs/NPCTank
onready var items_tile: TileMap = $TileMaps/Items
onready var grnd_tile: TileMap = $TileMaps/Grounds

# An AStar node used for path finding.
var astar: AStar2D
# Holds the top left index of used cell in ground tile.
var top_left_cell: Vector2
# Tile index difference
var in_d: int = 2



func _ready() -> void:
	Global.level = self
	
	astar = AStar2D.new()
	var cells_rows_num: int = int(grnd_tile.get_used_rect().size.x)
	var cells_cols_num: int = int(grnd_tile.get_used_rect().size.y)
	print(cells_rows_num, "   ", cells_cols_num)
	
	top_left_cell = Vector2(grnd_tile.get_used_rect().position)
	
	var cell_id: int
	var row: int = top_left_cell.x
	var col: int = top_left_cell.y
	while row < cells_rows_num + top_left_cell.x:
		while col < cells_cols_num + top_left_cell.y:
			var g_cell: Vector2 = Vector2(row, col)
			# Following line will ensure that cell index is not negetive so the cell
			# id for add_point is not negative
			var cell_positive: Vector2 = g_cell - top_left_cell
			cell_id = cell_positive.x * cells_rows_num + cell_positive.y
			
			# A tile position will be set as the graph node only if there is no item
			# around it.
			if (items_tile.get_cell(g_cell.x, g_cell.y) == -1 and
					items_tile.get_cell(g_cell.x - 1, g_cell.y - 1) == -1 and
					items_tile.get_cell(g_cell.x - 1, g_cell.y + 1) == -1 and
					items_tile.get_cell(g_cell.x + 1, g_cell.y - 1) == -1 and
					items_tile.get_cell(g_cell.x + 1, g_cell.y + 1) == -1 and
					items_tile.get_cell(g_cell.x, g_cell.y - 1) == -1 and
					items_tile.get_cell(g_cell.x, g_cell.y + 1) == -1 and
					items_tile.get_cell(g_cell.x - 1, g_cell.y) == -1 and
					items_tile.get_cell(g_cell.x + 1, g_cell.y) == -1):
				
				astar.add_point(cell_id,
					Vector2(g_cell.x, g_cell.y) * 64 + Vector2(32, 32))
				# Connecting this point to top or left point if they exists
				var top_cell: int = (cell_positive.x - in_d) * cells_rows_num + cell_positive.y
				if astar.has_point(top_cell):
					astar.connect_points(cell_id, top_cell)
			
				var left_cell: int = cell_positive.x * cells_rows_num + (cell_positive.y - in_d)
				if astar.has_point(left_cell):
					astar.connect_points(cell_id, left_cell)
				
				var top_left_cell: int = ((cell_positive.x - in_d) * cells_rows_num
						+ (cell_positive.y - in_d))
				if astar.has_point(top_left_cell):
					astar.connect_points(cell_id, top_left_cell)
				
				var top_right_cell: int = ((cell_positive.x - in_d) * cells_rows_num
						+ (cell_positive.y + in_d))
				if astar.has_point(top_right_cell):
					astar.connect_points(cell_id, top_right_cell)
			
			# Approximate path finding suffice for out purpose, so we skip one tile
			# in setting tiles as astar graph nodes.
			col += in_d
		row += in_d
		col = top_left_cell.y
	
	return
	

func _process(delta: float) -> void:
	update()
	


#func _draw() -> void:
#	var pnts: Array = astar.get_points()
#	for p in pnts:
#		draw_circle(astar.get_point_position(p), 10, Color.blue)
#
#	return
#


#func _draw() -> void:
#	var move_direction: Vector2 = npc.move_direction
#	draw_line(npc.position + move_direction, 
#		npc.position + move_direction * 150, Color.blue, 5)
#	draw_circle(npc.position + move_direction * 150, 10, Color.blue)
#
#	var patrol_direction: Vector2 = npc.patrol_direction
#	draw_line(npc.position + patrol_direction,
#		npc.position + patrol_direction * 150, Color.red, 5)
#	draw_circle(npc.position + patrol_direction * 150, 10, Color.red)
#
#	for pnt in npc.patrol_points:
#		draw_circle(pnt, 20, Color.black)
