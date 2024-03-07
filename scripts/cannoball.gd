extends Node2D

var move_speed = 400.0
var direction = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	# maybe I should make it auto based on move speed how long I want it to live
	#$Timer.wait_time = 0.6
	#$Timer.start()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = position.move_toward(position + direction*1000, delta * move_speed)

func fire(dir: Vector2):
	direction = dir

func _on_area_2d_area_entered(area):
	if area.name == "EnemyArea":
		print("hit enemy")
		# am I supposed to make the area the root?
		# or attach a script to the area?
		area.get_parent().kill()


func _on_timer_timeout():
	#move_speed = 0
	queue_free()
