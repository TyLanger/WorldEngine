extends Node2D

var resource_type = ResourceType.Wood

var wood_sprite = preload("res://sprites/log.png")
var stone_sprite = preload("res://sprites/rock.png")

@onready var sprite = $"Resource Sprite"
@onready var label = $"Resource Sprite/Count Label"

var count = 0

var target
var move_speed = 300
var moving = false

var going_to_combine = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target != null:
		if moving:
			global_position = position.move_toward(target.global_position, move_speed * delta)
			if global_position.distance_squared_to(target.global_position) < 1:
				moving = false
				if going_to_combine:
					# You've reached the destination and can delete yourself
					queue_free()
		else:
			global_position = target.global_position
		
func create(type, amount, follow_target):
	resource_type = type
	match resource_type:
		ResourceType.Wood:
			sprite.texture = wood_sprite
		ResourceType.Stone:
			sprite.texture = stone_sprite
	count = amount
	target = follow_target
	label.text = str(count)

func update_follow_target(new_target):
	target = new_target
	moving = true

func add_resources(amount):
	count += amount
	#print("adding resources: +", amount, " = ", count)
	label.text = str(count)

func get_resource_type():
	return resource_type

func follow_then_delete_on_arrival(new_target):
	target = new_target
	moving = true
	# will delete when it reaches the position
	going_to_combine = true
