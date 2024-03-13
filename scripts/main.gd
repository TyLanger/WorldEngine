extends Node2D

@export var drill_scn: PackedScene
@export var cannon_scn: PackedScene
var tower_build_menu

@export var snake_scn: PackedScene
var boss_spawned = false
var snakes_dead = 0

var snake_segments

# Called when the node enters the scene tree for the first time.
func _ready():
	tower_build_menu = $"Tower Build Menu"
	tower_build_menu.on_tower_build_button_pressed.connect(try_build_tower)
	tower_build_menu.on_destroy_pressed.connect(destroy_tower)

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

func destroy_tower():
	$"Castle Grid".destroy_tower()

func drill(direction, x, y, driller):
	#print("main coordinating drilling")
	match direction:
		Direction.Up:
			$"North Grid".drill_here(x, y, driller)
		Direction.Right:
			$"East Grid".drill_here(x, y, driller)
		Direction.Down:
			$"South Grid".drill_here(x, y, driller)
		Direction.Left:
			$"West Grid".drill_here(x, y, driller)
	

func random_swap_at(pos):
	$"Castle Grid".random_swap_at(pos)

func selected_update_ui(selected_tile):
	$"Tower Build Menu".show_info(selected_tile)
	
func spawn_boss(pos):
	# only spawn 1
	if !boss_spawned:
		boss_spawned = true
		snake_segments = []
		for i in 10:
			var snake = snake_scn.instantiate()
			add_child(snake)
			snake.global_position = pos
			snake.setup(i, i * 0.48)
			snake_segments.append(snake)
			
func snake_part_died(index):
	snakes_dead += 1
	#print("Segment ", index, " died. Total: ", snakes_dead)
	if snakes_dead == 10:
		#print("All snakes dead. You win!")
		snake_segments[0].really_die()
		snake_segments[9].really_die()
		win_game()
	if index == 0:
		#print("head died")
		return
	if index == 9:
		#print("tail died")
		return
	for i in 10:
		if i > index:
			if snake_segments[i] != null:
				snake_segments[i].speed_up(0.48)

func win_game():
	$"Tower Build Menu".win()
	
func lose_game():
	$"Tower Build Menu".lose()
