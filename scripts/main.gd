extends Node2D

@export var drill_scn: PackedScene
@export var cannon_scn: PackedScene
var tower_build_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	tower_build_menu = get_node("Tower Build Menu")
	tower_build_menu.on_tower_build_button_pressed.connect(try_build_tower)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("space"):
		build_drill()

func try_build_tower(tower):
	match tower:
		TowerType.Drill:
			build_drill()
		TowerType.Cannon:
			build_cannon()

func build_cannon():
	print("spawn cannon here: ", get_node("Castle Grid").get_selection_position())
	get_node("Castle Grid").spawn_tower(cannon_scn, TowerType.Cannon)

func build_drill():
	print("spawn drill here: ", get_node("Castle Grid").get_selection_position())
	get_node("Castle Grid").spawn_tower(drill_scn, TowerType.Drill)

func drill(direction, x, y):
	#print("main coordinating drilling")
	match direction:
		Direction.Up:
			$"North Grid".drill_here(x, y)
		Direction.Right:
			$"East Grid".drill_here(x, y)
	

func random_swap_at(pos):
	$"Castle Grid".random_swap_at(pos)

# unused
func camp_reached_3(pos):
	print("camp wants a push bomb from: ", pos)
	# global pos is (304, 96) (bottom row), (304, 0) for center, (304, -96) for top row
	# (-48, -304) for the north grid
	# grid can convert pos to grid
	# need main to coordinate from the camp's grid to the center grid
	# camp kinda knows where it is
	# it doesn't really know where to shoot
	# I could hard code it
	# if x==304, shoot left 80 units
	# how does the push bomb tell the center grid that it exploded?
	# main gives push bomb a ref to center_grid to call when it lands?
	if pos.y < -300:
		# north grid
		print()
	elif pos.x > 300:
		# east grid
		print()
	elif pos.y > 300:
		# south grid
		print()
	elif pos.x < -300:
		# west grid
		print()
	$"Castle Grid".random_swap_nearby(2,2)
	# (304, 96) maps to Castle(5,5) = (96, 96)
	# 304-96 = 208
	print("(5,5): ", $"Castle Grid".grid[5][5].global_position)
