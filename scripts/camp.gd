extends Node2D


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
	
