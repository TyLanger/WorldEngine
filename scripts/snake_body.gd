extends Node2D

var follow_target
var behind_segment

var follow_position

var base_move_speed = 100
var max_move_speed = 200
var move_speed = 0

@export var snake_tail: Texture

func _process(delta):
	if follow_target != null && move_speed == 0:
		if position.distance_squared_to(follow_target.position) > (48*48):
			move_speed = base_move_speed
	if move_speed > 0:
		if position.distance_squared_to(follow_target.position) > (48*48):
			position = position.move_toward(follow_target.position, move_speed * delta)
		
	# position is follower + (0, 48)
	# depending on facing
	# what happens at corners?
	
	# body segments just do the same path as the head?
	# stuff would overlap at corners, but does that matter?

func setup(target):
	follow_target = target

func make_tail():
	$"Snake Body".texture = snake_tail
	
func update_follow_pos(pos):
	follow_position = pos
