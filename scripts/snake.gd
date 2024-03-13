extends Node2D

# path
# how is it agnostic of spawn location?
# spawn and then run straight to the corner and then start the path
# north_path, etc
# start at the closest one and then go to the next

var just_spawned = true
var delay

var base_move_speed = 100
var max_move_speed = 200
var move_speed = 100
var path
var path_index = 0

var speed_time = 0

var current_direction
var spawn_direction

var follower

var health = 10
var my_segment
var dead = false

@export var body_sprite: Texture
@export var tail_sprite: Texture

var enemy_scene = preload("res://scenes/enemy.tscn")
var enemy_timer = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if just_spawned:
		if delay > 0:
			delay -= delta
		else:
			get_to_corner(delta)
	else:
		if speed_time > 0:
			speed_time -= delta
			# move twice is same as double speed, right?
			position = position.move_toward(path[path_index], base_move_speed * delta)
			if position.distance_squared_to(path[path_index]) < 1:
				path_index += 1
				if path.size() == path_index:
					# go to the next path
					path_index = 0
					get_next_path()
		position = position.move_toward(path[path_index], base_move_speed * delta)
		look_at(path[path_index])
		if position.distance_squared_to(path[path_index]) < 1:

			path_index += 1
			if path.size() == path_index:
				# go to the next path
				path_index = 0
				get_next_path()
		if my_segment == 0:
			# head can spawn enemies
			enemy_timer -= delta
			if enemy_timer <= 0:
				spawn_enemy()
				enemy_timer = 3.0
		elif my_segment == 9:
			# tail can spawn enemies slower
			enemy_timer -= delta
			if enemy_timer <= 0:
				spawn_enemy()
				enemy_timer = 5.0

func setup(segments, start_delay):
	calculate_spawn_direction()

	delay = start_delay
	my_segment = segments
	if segments > 0:
		$"Snake Head".texture = body_sprite
		if segments == 9:
			$"Snake Head".texture = tail_sprite
			enemy_timer = 5.0

func take_damage(damage):
	if just_spawned || dead:
		return
	health -= damage
	if health <= 0:
		kill()

func kill():
	get_parent().snake_part_died(my_segment)
	dead = true
	if my_segment == 0 || my_segment == 9:
		# head and tail can't die
		
		return
	queue_free()

func really_die():
	base_move_speed = 0

func speed_up(time):
	speed_time += time

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	get_parent().add_child(enemy)
	enemy.global_position = global_position

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
		look_at(position + Vector2(100, 0))
		if position.x > 350:
			# reached the corner
			# turn and go to the east grid
			just_spawned = false
			path = get_east_path()
	elif spawn_direction == Direction.Right:
		#print("snake in the east")
		
		# east grid
		position = position.move_toward(position + Vector2(0, 100), base_move_speed * delta)
		look_at(position + Vector2(0, 100))
		
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
		look_at(position + Vector2(-100, 0))
		
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
		look_at(position + Vector2(0, -100))
		
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
	#print("getting east path")
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
