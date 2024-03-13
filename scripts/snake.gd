extends Node2D

# path
# how is it agnostic of spawn location?
# spawn and then run straight to the corner and then start the path
# north_path, etc
# start at the closest one and then go to the next

var just_spawned = true

var base_move_speed = 100
var max_move_speed = 200
var move_speed = 100
var path
var path_index = 0

var current_direction
var spawn_direction

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if just_spawned:
		get_to_corner(delta)
	else:
		position = position.move_toward(path[path_index], base_move_speed * delta)
		if position.distance_squared_to(path[path_index]) < 1:
			path_index += 1
			if path.size() == path_index:
				# go to the next path
				path_index = 0
				get_next_path()

func calculate_spawn_direction():
	if global_position.y < -200:
		spawn_direction = Direction.Up
	elif global_position.x > 200:
		spawn_direction = Direction.Right
	elif global_position.y > 200:
		spawn_direction = Direction.Down
	elif global_position.x < -200:
		spawn_direction = Direction.Left

func get_to_corner(delta):
	# figure out what grid you're on
	if spawn_direction == Direction.Up:
		#print("snake in the north")
		#north grid
		# move right
		position = position.move_toward(position + Vector2(100, 0), base_move_speed * delta)
		if position.x > 350:
			# reached the corner
			# turn and go to the east grid
			just_spawned = false
			path = get_east_path()
	elif spawn_direction == Direction.Right:
		#print("snake in the east")
		
		# east grid
		position = position.move_toward(position + Vector2(0, 100), base_move_speed * delta)
		# needs to match the starting point of th next path
		if position.y > 255:
			# reached the corner
			# turn and go to the next grid
			just_spawned = false
			path = get_south_path()
	elif spawn_direction == Direction.Down:
		#print("snake in the south")
		
		# south grid
		position = position.move_toward(position + Vector2(-100, 0), base_move_speed * delta)
		# needs to match the starting point of th next path		
		if position.x < -399:
			# reached the corner
			# turn and go to the next grid
			just_spawned = false
			path = get_west_path()
	elif spawn_direction == Direction.Left:
		#print("snake in the west")
		
		# west grid
		position = position.move_toward(position + Vector2(0, -100), base_move_speed * delta)
		# needs to match the starting point of th next path
		if position.y < -255:
			# reached the corner
			# turn and go to the next grid
			#print("Reached the west corner")
			just_spawned = false
			path = get_north_path()

func get_next_path():
	match current_direction:
		Direction.Up:
			path = get_east_path()
		Direction.Right:
			path = get_south_path()
		Direction.Down:
			path = get_west_path()
		Direction.Left:
			path = get_north_path()

func get_north_path():
	var north_array = []
	north_array.append(Vector2(-96, -256))
	north_array.append(Vector2(-48, -256))
	north_array.append(Vector2(-48, -352))
	north_array.append(Vector2(0, -352))
	north_array.append(Vector2(0, -208))
	north_array.append(Vector2(96, -208))
	north_array.append(Vector2(96, -304))
	north_array.append(Vector2(352, -304))
	
	current_direction = Direction.Up
	return north_array

func get_east_path():
	print("getting east path")
	var east = []
	east.append(Vector2(352, -48))
	east.append(Vector2(256, -48))
	east.append(Vector2(256, 0))
	east.append(Vector2(304, 0))
	east.append(Vector2(304, 48))
	east.append(Vector2(304, 96))
	east.append(Vector2(256, 96))
	east.append(Vector2(256, 256))
	
	current_direction = Direction.Right
	
	return east

func get_south_path():
	var south = []
	
	south.append(Vector2(96, 256))
	south.append(Vector2(-48, 256))
	south.append(Vector2(-48, 352))
	south.append(Vector2(0, 352))
	south.append(Vector2(0, 208))
	south.append(Vector2(-96, 208))
	south.append(Vector2(-400, 208))
	
	current_direction = Direction.Down
	
	return south

func get_west_path():
	var west = []
	
	west.append(Vector2(-400, 96))
	west.append(Vector2(-400, 0))
	west.append(Vector2(-304, 0))
	west.append(Vector2(-304, 96))
	west.append(Vector2(-256, 96))
	west.append(Vector2(-256, 48))
	west.append(Vector2(-208, 48))
	west.append(Vector2(-208, 0))
	west.append(Vector2(-256, 0))
	west.append(Vector2(-256, -48))
	west.append(Vector2(-304, -48))
	west.append(Vector2(-304, -96))
	west.append(Vector2(-304, -256))
	
	current_direction = Direction.Left
	return west
