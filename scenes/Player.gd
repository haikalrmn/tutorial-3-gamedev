extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Welcome!") # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
export (int) var speed = 400
export (int) var dash_intensity = 7000
export (int) var jump_speed = -600
export (int) var GRAVITY = 1200
const UP = Vector2(0,-1)
export (int) var jump_state = 0
export (int) var DASH_DELAY = 0.25
export (int) var DASH_COOLDOWN = 1
export (int) var dash_timeout = DASH_DELAY #doubletap timeout
export (int) var dash_cd_timeout = DASH_COOLDOWN
export       var last_key = ""

var velocity = Vector2()

func get_input():
	velocity.x = 0
	var dash = 0
	$AnimatedSprite.animation = "default"
	if ((Input.is_action_just_pressed("right") and last_key == "right") or (Input.is_action_just_pressed("left") and last_key == "left")) and dash_timeout >= 0 and dash_cd_timeout <= 0: 
		dash = dash_intensity
		last_key = ""
		dash_cd_timeout = DASH_COOLDOWN
		print("just dashed, now cooldown " + str(dash_cd_timeout))
		
	
	if Input.is_action_just_pressed("right"):
		last_key = "right"
		dash_timeout = DASH_DELAY
		print("last_key right, cd timeout " + str(dash_cd_timeout))

	if Input.is_action_just_pressed("left"):
		last_key = "left"
		dash_timeout = DASH_DELAY
		print("last_key left, cd timeout " + str(dash_cd_timeout))
		
	if Input.is_action_pressed('right'):
		velocity.x += speed + dash
		$AnimatedSprite.animation = "Running"
		
	if Input.is_action_pressed('left'):
		velocity.x -= speed + dash
		$AnimatedSprite.animation = "Running"
	if is_on_floor() and Input.is_action_just_pressed('jump'):
		velocity.y = jump_speed
		jump_state = 1
		print(jump_state)
	if !is_on_floor() and jump_state == 1 and Input.is_action_just_pressed('jump'):
		velocity.y = jump_speed
		jump_state = 0
		print(jump_state)

func _physics_process(delta):
	velocity.y += delta * GRAVITY
	dash_timeout -= delta
	dash_cd_timeout -= delta
	get_input()
	velocity = move_and_slide(velocity, UP)
