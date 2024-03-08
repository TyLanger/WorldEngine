extends Node2D

var enemy_scene = preload("res://scenes/enemy.tscn")

# will be 1 when it appears
var times_moved = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func hide_sprite():
	get_node("CampSprite").visible = false
	
func show_sprite():
	get_node("CampSprite").visible = true
	get_node("Timer").start()

func camp_moved():
	times_moved += 1
	print("camp moved ", times_moved)
	if times_moved == 3:
		print("spawn push bomb")
		# where?
		# parent.parent.parent.parent?
		# tile.grid.main
		get_parent().get_parent().get_parent().camp_reached_3(global_position)

func spawn_enemy():
	#print("camp spawned enemy")
	var enemy = enemy_scene.instantiate()
	enemy.global_position = global_position
	# the enemy's parent is the main root node
	# if the grid is the parent, it gets (0,0) wrong
	get_parent().get_parent().get_parent().add_child(enemy)

func _on_timer_timeout():
	spawn_enemy()
