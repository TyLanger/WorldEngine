extends Node2D

@export var width: int
@export var height: int

@export var tile_scene: PackedScene


var grid

# Called when the node enters the scene tree for the first time.
func _ready():
	grid = []
	for i in width:
		var row = []
		for j in height:
			var tile = tile_scene.instantiate()
			
			var centered_x = i - width/2
			var centered_y = j - height/2
			tile.position = position + Vector2(48 * centered_x, 48 * centered_y)
			add_child(tile)
			row.append(tile)
		grid.append(row)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
