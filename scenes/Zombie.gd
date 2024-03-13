extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var movement_speed = 100
export var rng_seed = 0
onready var patrol_path = get_parent()
var direction = 1
var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.seed = rng_seed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if patrol_path.unit_offset == 1.0:
		direction = -1
		$AnimatedSprite.flip_h = true
		
	elif patrol_path.unit_offset == 0.0:
		direction = 1
		$AnimatedSprite.flip_h = false
		
	patrol_path.offset += movement_speed * delta * direction
	
	if $Timer.wait_time <= 0.01:
		var index = rng.randi_range(1, 3)
		var sound =  get_node("Timer/Zombie" + str(index))
		sound.play()
		$Timer.wait_time = rng.randi_range(5, 10)	
	
	$Timer.wait_time -= delta


func _on_LeftKillCollision_body_entered(body):
	pass # Replace with function body.


func _on_RightKillCollision_body_entered(body):
	pass # Replace with function body.
