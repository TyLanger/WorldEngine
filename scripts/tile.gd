extends Node2D

var start_pos
var anchor_pos
var grid_offset = Vector2(0,0)

var follow_mouse = false
var moving = false

var swappable = true

var has_tower = false
var tower_type
var my_tower
var has_camp = false
var camp_node
var has_resource = false
var resource_stack_node

var move_speed: float = 3.0
var max_speed: float = 20.0
var min_speed: float = 4.0
var accel: float = 1.7

# drill does 1 damage every 0.2s
# 15 is 3s to drill
# 25 is 5s to drill
var health = 25
var base_health = 25
#var health = 10
#var base_health = 10

@onready var sprite_node = get_node("Sprite2D")

@export var forest_tex: Texture
@export var mountain_tex: Texture
@export var field_tex: Texture
@export var spooky_tex: Texture

var tile_type = TileType.Field

var random_type = true

@export var camp_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	start_pos = position
	anchor_pos = start_pos
	#sprite_node = get_node("Sprite2D")
	sprite_node.texture = field_tex

	if random_type:
		choose_random_type()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# rotation decay
	rotation = move_toward(rotation, 0, 0.15 * delta)
	if follow_mouse:
		# clamp near the anchor point + 0.6 of a block
		var mouse = get_global_mouse_position()
		# account for the grid not being at (0,0)
		mouse -= grid_offset
		var x = clamp(mouse.x, anchor_pos.x - 32, anchor_pos.x + 32)
		var y = clamp(mouse.y, anchor_pos.y - 32, anchor_pos.y + 32)
		position = Vector2(x, y)
	elif moving:
		position.x = move_toward(position.x, anchor_pos.x, move_speed)
		position.y = move_toward(position.y, anchor_pos.y, move_speed)
		
		move_speed = clamp(move_speed + accel, min_speed, max_speed)
		if position.distance_squared_to(anchor_pos) < 0.1:
			reached_destination()

func can_swap():
	return swappable

func swap(new_pos):
	anchor_pos = new_pos
	
	move_speed = min_speed
	moving = true

func dragged_dir(dir):
	# you were dragged by the mouse this direction
	#match dir:
		#Direction.Up:
			#print("I was dragged up")
		#Direction.Right:
			#print("I was dragged right")
		#Direction.Down:
			#print("I was dragged down")
		#Direction.Left:
			#print("I was dragged left")
	
	if has_tower:
		my_tower.face_dir(dir)

func forced_dir(dir):
	# you were forced this direction by another tile pushing you
	#match dir:
		#Direction.Up:
			#print("I was forced up")
		#Direction.Right:
			#print("I was forced right")
		#Direction.Down:
			#print("I was forced down")
		#Direction.Left:
			#print("I was forced left")
	pass
	#if has_tower:
		#my_tower.face_dir(dir)

func pickup():
	follow_mouse = true
	z_index += 1 #should I just set it to 1?

func drop(new_pos):
	follow_mouse = false
	z_index -= 1 # should I just set it to 0?
	anchor_pos = new_pos
	
	move_speed = min_speed
	moving = true

func reached_destination():
	# when the tile "respawns" at the backside of the grid
	position = anchor_pos
	moving = false
	if !sprite_node.visible:
		sprite_node.visible = true
		if has_camp:
			camp_node.show_sprite()
	if has_camp:
		camp_node.camp_moved()

func has_drill():
	if has_tower:
		if tower_type == TowerType.Drill:
			return true
	return false

func has_cannon():
	if has_tower:
		if tower_type == TowerType.Cannon:
			return true
	return false

func take_drill_damage():
	health -= 1
	# do a wiggle
	# random rotation and then fade back to normal?
	if health % 2 == 0:
		rotation = 0.07
		#rotate(0.2)
	else:
		rotation = -0.07
		#rotate(-0.2)

func get_health():
	return health

func get_drilled(driller):
	# reset hp
	health = base_health
	give_loot(driller)
	sprite_node.visible = false
	rotate(-0.1)
	if has_camp:
		camp_node.queue_free()
		has_camp = false
	choose_random_type()
	create_camp()

func give_loot(driller):
	var wood = 0
	var stone = 0
	var gold = 0
	if has_camp:
		print("give camp loot")
		gold = 5
	match tile_type:
		TileType.Forest:
			#print("give forest loot")
			wood = 3
		TileType.Mountain:
			#print("give mountain loot")
			stone = 3
		TileType.Field:
			print("give field loot")
		TileType.SpookyTree:
			wood = 5
	driller.add_resources(wood, stone, gold)

func give_resource_stack(new_resource_stack):
	#print("tile now has resource")
	has_resource = true
	resource_stack_node = new_resource_stack

func get_resource_stack():
	return resource_stack_node

func is_tree():
	return tile_type == TileType.Forest

func make_spooky_tree():
	# probably just change to a different tree sprite
	tile_type = TileType.SpookyTree
	sprite_node.texture = spooky_tex

func choose_random_type():
	var r = randi_range(0, 1)
	#r = 0
	match r:
		0:
			sprite_node.texture = forest_tex
			tile_type = TileType.Forest
		1:
			sprite_node.texture = mountain_tex
			tile_type = TileType.Mountain
		2:
			sprite_node.texture = field_tex
			tile_type = TileType.Field

func create_camp():
	var r = randi_range(0, 15)
	# 10% chance to make a camp
	if r == 0:
		var camp = camp_scene.instantiate()
		camp.hide_sprite()
		add_child(camp)
		camp_node = camp
		has_camp = true
		# only put camps on fields
		sprite_node.texture = field_tex
		tile_type = TileType.Field

func can_build_here() -> bool:
	if has_tower:
		return false
	if has_resource:
		return false
	return true

func spawn_tower(tower_scn: PackedScene, t_type):
	var tower = tower_scn.instantiate()
	add_child(tower)
	has_tower = true
	tower_type = t_type
	my_tower = tower

func _on_area_2d_input_event(_viewport, _event, _shape_idx):
	pass
	#if event is InputEventMouseButton:
		#if event.pressed:
			#print("tile clicked at ", position)

