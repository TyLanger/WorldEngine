extends Node2D

var move_speed = 50.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = position.move_toward(Vector2.ZERO, delta * move_speed)
	if position.distance_squared_to(Vector2.ZERO) < 0.1:
		print("Enemy reached castle")
		queue_free()
	
