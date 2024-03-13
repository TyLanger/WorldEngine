extends Node2D

var move_speed = 42.0
@onready var sprite = $"EnemySprite"
var castle
var health = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	castle = get_parent().get_node("Castle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dir = Vector2.ZERO - position
	# move in a straight line and then a diagonal
	# they stick to the tiles this way instead of cutting corners between tiles
	# I plan to have towers attack a specific tiles
	# so this should make it more clear what tile they're on
	# plus it looks neat
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			dir = Vector2(1.0, 0.0)
		else:
			dir = Vector2(-1.0, 0.0)
	elif abs(dir.x) < abs(dir.y):
		if dir.y > 0:
			dir = Vector2(0.0, 1.0)
		else:
			dir = Vector2(0.0, -1.0)
	else:
		dir = dir.normalized()
	
	if dir.x > 0:
		sprite.scale = Vector2(-1.0, 1.0)
	
	position = position.move_toward(position + dir, delta * move_speed)
	if position.distance_squared_to(Vector2.ZERO) < 100:
		#print("Enemy reached castle")
		castle.take_damage()
		queue_free()

func take_damage(damage):
	health -= damage
	if health <= 0:
		kill()

func kill():
	#print("Enemy killed")
	queue_free()
