extends Node2D

var resource_type = ResourceType.Wood

var wood_sprite = preload("res://sprites/log.png")
var stone_sprite = preload("res://sprites/rock.png")

@onready var sprite = $"Resource Sprite"

var count = 0

var target
var move_speed = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target != null:
		#global_position = position.move_toward(target.global_position, move_speed * delta)
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

func add_resources(amount):
	count += amount
	print("adding resources: +", amount, " = ", count)

func get_resource_type():
	return resource_type

