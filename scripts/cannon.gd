extends Node2D

@export var cannonball_scn: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_area_entered(area: Area2D):
	if area.name == "EnemyArea":
		fire_cannonball()

func fire_cannonball():
	var ball = cannonball_scn.instantiate()
	ball.fire(get_fire_direction())
	ball.set_deferred("global_position", global_position)
	get_parent().get_parent().get_parent().call_deferred("add_child", ball)

func get_fire_direction():
	return Vector2.RIGHT
