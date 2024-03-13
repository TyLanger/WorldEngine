extends Node2D

var enemy_scene = preload("res://scenes/enemy.tscn")
var artillery_scene = preload("res://scenes/camp_artillery.tscn")
var artillery_indicator_scene = preload("res://scenes/camp_artillery_indicator.tscn")

# will be 1 when it appears
var times_moved = 0

var art_flight_time = 3.0

var art_start: Vector2
var art_goal: Vector2
var art_time_alive
var art_node

var art_alive = false

var indicator_node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# just move the projectile myself instead of adding a script to it
	if art_alive:
		art_time_alive += delta
		var t = art_time_alive/art_flight_time
		art_node.set_global_position( lerp(art_start, art_goal, clamp(t, 0.0, 1.0)) )
		if art_time_alive > art_flight_time:
			# reached dest
			art_alive = false
			art_node.queue_free()
			indicator_node.queue_free()
			# tile.grid.main
			get_parent().get_parent().get_parent().random_swap_at(art_goal)


func hide_sprite():
	get_node("CampSprite").visible = false
	
func show_sprite():
	get_node("CampSprite").visible = true
	get_node("Timer").start()

func camp_moved():
	times_moved += 1
	if times_moved == 3:
		fire_artillery()

func fire_artillery():
	# spawn
	var global_destination = calculate_fire_destination()
	var art = artillery_scene.instantiate()
	art.global_position = global_position
	# tile.grid
	get_parent().get_parent().add_child(art)
	
	art_node = art
	art_alive = true
	art_start = global_position
	art_goal = global_destination
	art_time_alive = 0
	
	# place indicator
	indicator_node = artillery_indicator_scene.instantiate()
	
	# tile.grid
	get_parent().get_parent().add_child(indicator_node)
	# put this after add child so it's accurate
	indicator_node.global_position = global_destination

func calculate_fire_destination():
	# factor of 208
	if global_position.y < -300:
		# north grid
		return global_position + Vector2(0, 208)
	elif global_position.x > 300:
		# east grid
		return global_position + Vector2(-208, 0)
	elif global_position.y > 300:
		# south grid
		return global_position + Vector2(0, -208)
	elif global_position.x < -300:
		# west grid
		return global_position + Vector2(208, 0)


func spawn_enemy():
	if times_moved > 1:
		#print("camp spawned enemy")
		var enemy = enemy_scene.instantiate()
		enemy.global_position = global_position
		# the enemy's parent is the main root node
		# if the grid is the parent, it gets (0,0) wrong
		get_parent().get_parent().get_parent().add_child(enemy)

func _on_timer_timeout():
	spawn_enemy()
