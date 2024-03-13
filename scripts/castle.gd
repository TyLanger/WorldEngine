extends Node2D

var health = 20

@onready var health_bar = $"Castle Sprite/HealthBar"
@onready var damage_bar = $"Castle Sprite/HealthBar/DamageBar"
@onready var timer = $"Castle Sprite/HealthBar/Timer"

# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar.max_value = health
	health_bar.value = health
	damage_bar.max_value = health
	damage_bar.value = health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func take_damage():
	health -= 1
	if health <= 0:
		health = 0
		#print("dead castle")
		get_parent().lose_game()
	
	health_bar.value = health
	timer.start()


func _on_timer_timeout():
	damage_bar.value = health
