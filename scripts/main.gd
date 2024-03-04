extends Node2D

@export var drill_scn: PackedScene
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

func build_drill():
	print("spawn drill here: ", get_node("Castle Grid").get_selection_position())
	get_node("Castle Grid").spawn_tower(drill_scn)

func operate_drills():
	# check in castle grid
	# at the specific tiles
	# if they have drills, turn them on
	# and then kill the corresponding resource tiles?
	
	# north is [1][0], [2][0], [3][0], ...
	#if get_node("Castle Grid").grid[1][0].has_tower:
		#get_node("North Grid").grid[0][4].get_node("Sprite2D").visible = false
	#if get_node("Castle Grid").grid[2][0].has_tower:
		#get_node("North Grid").grid[1][4].get_node("Sprite2D").visible = false
	
	# mine north
	for i in range(1, 6):
		if get_node("Castle Grid").grid[i][0].has_tower:
			get_node("North Grid").drill_here(i-1, 4)
			
	# mine east
	for i in range(1, 6):
		if get_node("Castle Grid").grid[6][i].has_tower:
			get_node("East Grid").drill_here(0, i-1)


func _on_drill_timer_timeout():
	operate_drills()
