extends Node2D

var start_pos
var anchor_pos
var grid_offset = Vector2(0,0)

var follow_mouse = false
var moving = false

var swappable = true

var has_tower = false
var has_camp = false
var camp_node

var move_speed: float = 3.0
var max_speed: float = 20.0
var min_speed: float = 4.0
var accel: float = 1.7

var sprite_node

@export var forest_tex: Texture
@export var mountain_tex: Texture

var tile_type: TileType

@export var camp_scene: PackedScene

enum TileType {
	Forest, Mountain
}

# Called when the node enters the scene tree for the first time.
func _ready():
	start_pos = position
	anchor_pos = start_pos
	sprite_node = get_node("Sprite2D")
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

func drop(new_pos):
	follow_mouse = false
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

func choose_random_type():
	var r = randi_range(0, 2)
	match r:
		0:
			sprite_node.texture = forest_tex
			tile_type = TileType.Forest
		1:
			sprite_node.texture = mountain_tex
			tile_type = TileType.Mountain

func create_camp():
	var r = randi_range(0, 10)
	# 10% chance to make a camp
	if r == 0:
		var camp = camp_scene.instantiate()
		camp.hide_sprite()
		add_child(camp)
		camp_node = camp
		has_camp = true

func _on_area_2d_input_event(_viewport, _event, _shape_idx):
	pass
	#if event is InputEventMouseButton:
		#if event.pressed:
			#print("tile clicked at ", position)

