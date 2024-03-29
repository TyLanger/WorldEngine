extends Node2D

@export var cannonball_scn: PackedScene
var cannonball_time = 0.3

var facing = Direction.Up

var wood_needed = 4
var stone_needed = 7

@onready var timer = $"Timer"
@onready var collision_shape = $"Area2D/CollisionShape2D"

@onready var sprite = $"Cannon Sprite"
@export var normal_sprite: Texture
var blueprint_mode = true

var upgrade_timer = 30

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if blueprint_mode:
		if wood_needed <= 0 && stone_needed <= 0:
			blueprint_mode = false
			sprite.texture = normal_sprite
	if upgrade_timer > 0:
		if wood_needed <= 0 && stone_needed <= 0:
			upgrade_timer -= delta
			if upgrade_timer <= 0:
				upgrade_fire_range()


func _on_area_2d_area_entered(area: Area2D):
	if area.name == "EnemyArea":
		fire_cannonball()

func fire_cannonball():
	if can_fire():
		var ball = cannonball_scn.instantiate()
		ball.fire(get_fire_direction(), cannonball_time)
		ball.set_deferred("global_position", global_position)
		get_parent().get_parent().get_parent().call_deferred("add_child", ball)
		# turn the collider off
		collision_shape.set_deferred("disabled", true)
		timer.start()

func can_fire():
	if wood_needed > 0 || stone_needed > 0:
		return false
	return true

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

func upgrade_fire_range():
	# this works
	# but how should I trigger it?
	# reuse wood_needed, etc
	# but then it stops shooting. Maybe that's fine
	# after 30s seems easy enough
	collision_shape.set_deferred("disabled", true)
	$"Area Sprite".visible = false
	collision_shape = $"Area2D2/CollisionShape2D"
	collision_shape.set_deferred("disabled", false)
	$"Area Sprite2".visible = true
	cannonball_time = 0.45

func _on_timer_timeout():
	collision_shape.set_deferred("disabled", false)
