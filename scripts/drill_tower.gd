extends Node2D

var facing = Direction.Up

var drill_rate_ms = 200
var next_drill_time = 0

var wood_count = 0
var stone_count = 0
var gold_count = 0

var grid
var main

var resource_stack_scn = preload("res://scenes/resource_stack.tscn")
var my_stack
var has_internal_stack = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#is_correct_facing_and_position()
	grid = get_parent().get_parent()
	main = grid.get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Time.get_ticks_msec() > next_drill_time:
		if is_correct_facing_and_position() && can_i_drill():
			next_drill_time = Time.get_ticks_msec() + drill_rate_ms
			# drill something
			# figure out where I am and where my target must be
			# target_tile.take_drill_damage()
			drill_target()
	if has_internal_stack:
		# try to dump it behind you
		#print("try dumping")
		dump_resources()

func can_i_drill():
	#print("no")
	# if my internal storage is free, rock on
	# if my storage is full, but the next tile is the same, rock on
	# else no
	
	# check internal
	if !has_internal_stack:
		return true
	# elif same type

func add_resources(wood, stone, gold):
	
	gold_count += gold
	
	if has_internal_stack:
		#print("Adding to existing")
		match my_stack.get_resource_type():
			ResourceType.Wood:
				my_stack.add_resources(wood)
			ResourceType.Stone:
				my_stack.add_resources(stone)
	elif wood > 0 || stone > 0:
		var stack = resource_stack_scn.instantiate()
		#tile.grid
		get_parent().get_parent().add_child(stack)
		# where should it spawn?
		# maybe at where it was drilled?
		# for now, spawn on the drill tower
		stack.global_position = global_position
		if wood > 0:
			stack.create(ResourceType.Wood, wood, self)
		elif stone > 0:
			stack.create(ResourceType.Stone, stone, self)

		has_internal_stack = true
		my_stack = stack

func dump_resources():
	# tile.grid
	var my_point = grid.nearest_tile(global_position)
	var behind = my_point
	#var v = Vector2i()
	match facing:
		Direction.Up:
			# what's behind me?
			behind.y += 1
		Direction.Right:
			behind.x -= 1
		Direction.Down:
			behind.y -= 1
		Direction.Left:
			behind.x += 1
	
	# tile.grid
	if grid.try_dump(behind.x, behind.y, my_stack):
		has_internal_stack = false

func drill_target():
	# assume we have correct facing and position
	# tile.grid
	var my_point = grid.nearest_tile(global_position)
	match facing:
		Direction.Up:
			# I am (1,0) to (5,0)
			# maps to (0,4) to (4,4)
			# tile.grid.main			
			main.drill(Direction.Up, my_point.x-1, 4, self)
		Direction.Right:
			# if we are in Center(6,1), our target is East(0,0)
			# our pos will be (144, -96)
			# if we are in Center(6,2), our target is East(0,1)
			# our pos will be (144, -48)
			# tile.grid.main			
			main.drill(Direction.Right, 0, my_point.y-1, self)
		Direction.Down:
			# I am (1,6) to (5,6)
			# maps to (0,0) to (4,0)
			# tile.grid.main			
			main.drill(Direction.Down, my_point.x-1, 0, self)
		Direction.Left:
			# I am (0,1) to (0,5)
			# maps to (4,0) to (4,4)
			# tile.grid.main			
			main.drill(Direction.Left, 4, my_point.y-1, self)

func is_correct_facing_and_position() -> bool:
	# can only drill if on the outskirts
	# outskirts is 3x48 = 144 in one axis
	if abs(global_position.x) >= 144 && abs(global_position.y) >= 144:
		#print("at a corner. Can't drill")
		return false
	
	if global_position.y <= -144:
		#print("up outskirts")
		if facing == Direction.Up:
			return true
	elif global_position.x >= 144:
		#print("right outskirts")
		if facing == Direction.Right:
			return true
	elif global_position.y >= 144:
		#print("bottom outskirts")
		if facing == Direction.Down:
			return true
	elif global_position.x <= -144:
		#print("left outskirts")
		if facing == Direction.Left:
			return true
	
	return false
	#match facing:
		#Direction.Up:

func face_dir(dir):
	facing = dir
	match dir:
		Direction.Up:
			rotation_degrees = 0
		Direction.Right:
			rotation_degrees = 90
		Direction.Down:
			rotation_degrees = 180
		Direction.Left:
			rotation_degrees = 270
