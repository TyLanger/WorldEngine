extends Control

signal on_tower_build_button_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_drill_button_pressed():
	on_tower_build_button_pressed.emit(TowerType.Drill)
