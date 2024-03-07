extends Node2D

@export var cannonball_scn: PackedScene

var facing = Direction.Up

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
	match facing:
		Direction.Up:
			return Vector2(0, -1)
		Direction.Right:
			return Vector2(1, 0)
		Direction.Down:
			return Vector2(0, 1)
		Direction.Left:
			return Vector2(-1, 0)

func face_dir(dir):
	facing = dir
	match dir:
		Direction.Up:
			rotation_degrees = 0
		Direction.Right:
			rotation_degrees = 90
		Direction.Down:
			rotation_degrees = 180
		Direction.Left:
			rotation_degrees = 270
