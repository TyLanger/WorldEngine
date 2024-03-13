extends Control

signal on_tower_build_button_pressed
signal on_destroy_pressed

@onready var forest = $"Forest Info Label"
@onready var mountain = $"Mountain Info Label"
@onready var spooky = $"Spooky Info Label"
@onready var field = $"Field Info Label"

@onready var drill = $"Drill Info Label"
@onready var cannon = $"Cannon Info Label"
@onready var castle = $"Castle Info Label"
@onready var camp = $"Camp Info Label"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_info(selected_tile):
	
	var selected_tile_type = selected_tile.tile_type
	hide_all_tiles()
	hide_all_towers()
	match selected_tile_type:
		TileType.Forest:
			forest.visible = true
		TileType.Mountain:
			mountain.visible = true
		TileType.Field:
			field.visible = true
		TileType.SpookyTree:
			spooky.visible = true
	
	if selected_tile.has_tower:
		if selected_tile.has_drill():
			drill.visible = true
			# update with correct stats
			update_drill(selected_tile.my_tower)
		elif selected_tile.has_cannon():
			cannon.visible = true
			update_cannon(selected_tile.my_tower)
	elif selected_tile.has_camp:
		camp.visible = true
	
	# how to get castle?
	# it's not attached to a tile, it just floats above

func hide_all_tiles():
	forest.visible = false
	mountain.visible = false
	field.visible = false
	spooky.visible = false
	
func hide_all_towers():
	drill.visible = false
	cannon.visible = false
	castle.visible = false
	camp.visible = false

func update_drill(tower):
	var wood = tower.wood_needed
	var stone = tower.stone_needed
	if wood == 0 && stone == 0:
		drill.text = "Drill Tower
		Drag near resources 
		to drill them"
		return
	drill.text = "Drill Tower
Resources Needed:
"+ str(5-wood) + "/5 wood
"+ str(3-stone) + "/3 stone"

func update_cannon(tower):
	var wood = tower.wood_needed
	var stone = tower.stone_needed
	if wood == 0 && stone == 0:
		cannon.text = "Cannon Tower
		Aim towards enemies"
		return
	cannon.text = "Cannon Tower
Resources Needed:
"+ str(4-wood) + "/4 wood
"+ str(7-stone) + "/7 stone"

func win():
	$"Win Label".visible = true

func lose():
	$"Lose Label".visible = true

func _on_drill_button_pressed():
	on_tower_build_button_pressed.emit(TowerType.Drill)
	$"Cannon Button".visible = true

func _on_cannon_button_pressed():
	on_tower_build_button_pressed.emit(TowerType.Cannon)


func _on_destroy_button_pressed():
	on_destroy_pressed.emit()
	#get_parent().get_parent().destroy_Button_pressed()
