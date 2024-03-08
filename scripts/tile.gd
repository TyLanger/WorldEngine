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

var move_speed: float = 3.0
var max_speed: float = 20.0
var min_speed: float = 4.0
var accel: float = 1.7

@onready var sprite_node = get_node("Sprite2D")

@export var forest_tex: Texture
@export var mountain_tex: Texture
@export var field_tex: Texture

var tile_type = TileType.Field

var random_type = true

@export var camp_scene: PackedScene

enum TileType {
	Forest, Mountain, Field
}

# Called when the node enters the scene tree for the first time.
func _ready():
	start_pos = position
	anchor_pos = start_pos
	#sprite_node = get_node("Sprite2D")
	sprite_node.texture = field_tex

	if random_type:
		choose_random_type()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
			reached_desitation()

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

func reached_desitation():
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

func get_drilled():
	give_loot()
	sprite_node.visible = false
	if has_camp:
		camp_node.queue_free()
		has_camp = false
	choose_random_type()
	create_camp()

func give_loot():
	if has_camp:
		print("give camp loot")
	match tile_type:
		TileType.Forest:
			print("give forest loot")
		TileType.Mountain:
			print("give mountain loot")
		TileType.Field:
			print("give field loot")

func choose_random_type():
	var r = randi_range(0, 2)
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
	var r = randi_range(0, 10)
	# 10% chance to make a camp
	if r == 0:
		var camp = camp_scene.instantiate()
		camp.hide_sprite()
		add_child(camp)
		camp_node = camp
		has_camp = true

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

