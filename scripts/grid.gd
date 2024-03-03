extends Node2D

@export var grid_width: int
@export var grid_height: int

@export var tile_scene: PackedScene

var tile_width = 48
var offset = 0

var grid

var carrying_tile = false
var carry_point

var is_tile_selected = false
var tile_selected

@export var gravity_diretion = Direction.Down

enum Direction {
	Up, Right, Down, Left
}

# Called when the node enters the scene tree for the first time.
func _ready():
	grid = []
	for i in grid_width:
		var row = []
		for j in grid_height:
			var tile = tile_scene.instantiate()
			# give the grid's position
			# so tiles can follow the mouse without the grid being at (0,0)
			tile.grid_offset = position
			
			var area = tile.get_child(0).get_node("Area2D")
			area.input_event.connect(_on_tile_clicked)
			
			var centered_x = i - grid_width/2
			var centered_y = j - grid_height/2
			tile.position = position + Vector2(tile_width * centered_x, tile_width * centered_y)
			add_child(tile)
			row.append(tile)
		grid.append(row)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	process_swapping()
	if Input.is_action_just_released("mouse_left") && carrying_tile:
		tile_dropped()

func get_selection_position():
	if is_tile_selected:
		return tile_selected.position
	return Vector2.ZERO
	
func spawn_tower(tower_scn: PackedScene):
	var tower = tower_scn.instantiate()
	tile_selected.add_child(tower)
	tile_selected.has_tower = true

func process_swapping():
	if carrying_tile:
		# when you pass another tile, swap it to where I used to be
		var other_point = nearest_tile(get_global_mouse_position())
		#var other_point = nearest_neighbour(get_global_mouse_position())
		# if I just start with nearest_neighbour, I get flickering
		# I think I'm hovering over what I picked and nearest neighbour is forcing
		# it to a neighbour when I'm hovering over myself
		try_swap(other_point)

func try_swap(other_point: TilePoint):
	# can the tile be swapped?
	if other_point.x == carry_point.x && other_point.y == carry_point.y:
		# don't swap yourself
		return
	# are the tiles neighbours?
	if !are_neighbours(carry_point, other_point):
		# if the mouse isn't over a neighbour,
		# choose the neighbour the mouse is closest to
		other_point = get_intended_swap_from_mouse_pos(get_global_mouse_position())
	# i.e. don't swap over top of a non-swappable wall or river, etc.	
	if !grid[other_point.x][other_point.y].can_swap():
		return
	
	# tell it that it got swapped?
	# only runs for the tile being force-moved, not the one in your hand.
	# Should this be a signal? Maybe in swap_grid?
	grid[other_point.x][other_point.y].swap(anchor_from_point(carry_point))
	# anchor pos is the grid point the tile is anchored to
	# you can't drag it too far away from the anchor
	# this updates the anchor of the currently held tile 
	# as it swaps other tiles out of the way
	grid[carry_point.x][carry_point.y].anchor_pos = anchor_from_point(other_point)
	
	swap_grid(carry_point, other_point)
	carry_point = other_point

func drill_here(x: int, y: int):
	grid[x][y].get_drilled()
	#swap this tile along the column to the top of the grid
	if gravity_diretion == Direction.Down:
		swap_col_down(x)
	elif gravity_diretion == Direction.Left:
		swap_row_left(y)

func swap_col_down(x: int):
	# drill broke the bottom
	# it needs to move to the top
	# every other tile moves down 1
	# y = 4 is the bottom
	# y = 0 is the top
	var temp = grid[x][grid_height-1]
	for i in (grid_height-1):
		# height = 5
		# 0, 1, 2, 3,
		var offset = grid_height - 1 - i
		# 5 - 2 - (0,1,2,3)
		# 4, 3, 2, 1
		grid[x][offset] = grid[x][offset - 1]
	grid[x][0] = temp
	
	var tile_p = TilePoint.new()
	tile_p.x = x
	for i in grid_height:
		tile_p.y = i
		grid[x][i].swap(anchor_from_point(tile_p))

func swap_row_left(y: int):
	# left edge is 0
	var temp = grid[0][y]
	for i in (grid_width-1):
		grid[i][y] = grid[i+1][y]
	grid[grid_width-1][y] = temp
	
	var tile_p = TilePoint.new()
	tile_p.y = y
	for i in grid_width:
		tile_p.x = i
		grid[i][y].swap(anchor_from_point(tile_p))

func swap_grid(a: TilePoint, b: TilePoint):
	var temp = grid[a.x][a.y]
	grid[a.x][a.y] = grid[b.x][b.y]
	grid[b.x][b.y] = temp

func _on_tile_clicked(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == 1:
			tile_clicked()

func tile_clicked():
	is_tile_selected = true
	var tile_selected_point = nearest_tile(get_global_mouse_position())
	tile_selected = grid[tile_selected_point.x][tile_selected_point.y]
	if tile_selected.can_swap():
		tile_selected.pickup()
		carrying_tile = true
		carry_point = nearest_tile(get_global_mouse_position())
	
func tile_dropped():
	carrying_tile = false
	grid[carry_point.x][carry_point.y].drop(anchor_from_point(carry_point))



func is_over_tile(click_pos: Vector2):
	# forward
	# x = i - width/2
	# v2.x = width * x
	# backwards
	# x = point / width
	# i = x + width/2
	
	# account for grids not being at (0,0)
	# 2x bc the grids are centered
	click_pos -= position*2
	
	# + width/2 accounts for the center of the tile
	# vs the math conversion of point to tile coords
	# If I don't have it, you need to click on the bottom right corner of a tile
	# if you click on the other 3/4 of the tile, it maps to the adjacent tiles
	var x = (click_pos.x + tile_width/2) / tile_width
	var i = x + grid_width/2
	var y = (click_pos.y + tile_width/2) / tile_width
	var j = y + grid_height/2
	
	return i >= 0 && j >= 0 && i < grid_width && j < grid_height


func nearest_tile(click_pos: Vector2):
	click_pos -= position*2

	var x = (click_pos.x + tile_width/2) / tile_width
	var i = x + grid_width/2
	var y = (click_pos.y + tile_width/2) / tile_width
	var j = y + grid_height/2
	
	var point = TilePoint.new()
	point.x = clamp(int(i), 0, grid_width - 1)
	point.y = clamp(int(j), 0, grid_height - 1)
	return point

func get_intended_swap_from_mouse_pos(click_pos: Vector2):
	# mouse to neighbour
	# given the currently picked up tile
	# and the mouse direction,
	# what neighbour does this map to?
	# mouse can be the whole screen away. Just want the neighbour most in the direction of the mouse
	var carry_vec2 = anchor_from_point(carry_point)
	var direction_v2 = click_pos - carry_vec2
	
	# if direction is (+, +), check which is bigger
	# if dir is (++++, +), the nearest neighbour is to the right (+1, 0)
	var neighbour = TilePoint.new()
	if abs(direction_v2.x) > abs(direction_v2.y):
		if direction_v2.x > 0:
			neighbour.x = clamp(carry_point.x + 1, 0, grid_width-1)
			neighbour.y = carry_point.y
		else:
			neighbour.x = clamp(carry_point.x - 1, 0, grid_width-1)
			neighbour.y = carry_point.y
	else:
		if direction_v2.y > 0:
			neighbour.x = carry_point.x
			neighbour.y = clamp(carry_point.y + 1, 0, grid_height-1)
		else:
			neighbour.x = carry_point.x
			neighbour.y = clamp(carry_point.y - 1, 0, grid_height-1)
	return neighbour

func anchor_from_point(point):
	# forward
	# x = i - width/2
	# v2.x = width * x
	var x = point.x - grid_width/2
	var y = point.y - grid_height/2
	return position + Vector2(tile_width * x, tile_width * y)

func are_neighbours(a: TilePoint, b: TilePoint):
	if a.x == b.x:
		if abs(a.y - b.y) == 1:
			return true
	if a.y == b.y:
		if abs(a.x - b.x) == 1:
			return true
	return false

func are_diagonal(a: TilePoint, b: TilePoint):
	if abs(a.y - b.y) == 1 && abs(a.x - b.x) == 1:
		return true
	return false

class TilePoint:
	var x: int
	var y: int
