extends Node2D

var facing = Direction.Up

var drill_rate_ms = 200
var next_drill_time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#is_correct_facing_and_position()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Time.get_ticks_msec() > next_drill_time:
		if is_correct_facing_and_position():
			next_drill_time = Time.get_ticks_msec() + drill_rate_ms
			# drill something
			# figure out where I am and where my target must be
			# target_tile.take_drill_damage()
			drill_target()

func drill_target():
	# assume we have correct facing and position
	# tile.grid
	var my_point = get_parent().get_parent().nearest_tile(global_position)
	match facing:
		Direction.Up:
			# I am (1,0) to (5,0)
			# maps to (0,4) to (4,4)
			# tile.grid.main			
			get_parent().get_parent().get_parent().drill(Direction.Up, my_point.x-1, 4)
		Direction.Right:
			# if we are in Center(6,1), our target is East(0,0)
			# our pos will be (144, -96)
			# if we are in Center(6,2), our target is East(0,1)
			# our pos will be (144, -48)
			# tile.grid.main			
			get_parent().get_parent().get_parent().drill(Direction.Right, 0, my_point.y-1)
		Direction.Down:
			# I am (1,6) to (5,6)
			# maps to (0,0) to (4,0)
			# tile.grid.main			
			get_parent().get_parent().get_parent().drill(Direction.Down, my_point.x-1, 0)
		Direction.Left:
			# I am (0,1) to (0,5)
			# maps to (4,0) to (4,4)
			# tile.grid.main			
			get_parent().get_parent().get_parent().drill(Direction.Left, 4, my_point.y-1)

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
