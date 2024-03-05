extends Node2D

var enemy_scene = preload("res://scenes/enemy.tscn")

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
	
func spawn_enemy():
	#print("camp spawned enemy")
	var enemy = enemy_scene.instantiate()
	enemy.global_position = global_position
	# the enemy's parent is the main root node
	# if the grid is the parent, it gets (0,0) wrong
	get_parent().get_parent().get_parent().add_child(enemy)

func _on_timer_timeout():
	spawn_enemy()
