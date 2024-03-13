extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Welcome to the game")
	print("Press A or D to move left/right.")
	print("Press ctrl to crouch.")
	print("Press space to jump to crouch.")
	print("All assets and sound effects belong to their respective owners.")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
export (int) var speed = 300
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
export       var DEBUG = false
export (int) var speed_multiplier = 1
export (int) var climb_speed = 3


var velocity = Vector2()
var climbable = false
var enemy = null
var left_killable = false
var right_killable = false

				
func get_input():
	velocity.x = 0
	var dash = 0
	if ((Input.is_action_just_pressed("right") and last_key == "right") or (Input.is_action_just_pressed("left") and last_key == "left")) and dash_timeout >= 0 and dash_cd_timeout <= 0: 
		dash = dash_intensity
		last_key = ""
		dash_cd_timeout = DASH_COOLDOWN
		$AudioStreamPlayer.play(0.96)
		if DEBUG: print("just dashed, now cooldown " + str(dash_cd_timeout))
		print(dash)
		
	if Input.is_action_just_pressed("right"):
		last_key = "right"
		dash_timeout = DASH_DELAY
		if DEBUG:print("last_key right, cd timeout " + str(dash_cd_timeout))

	if Input.is_action_just_pressed("left"):
		last_key = "left"
		dash_timeout = DASH_DELAY
		if DEBUG: print("last_key left, cd timeout " + str(dash_cd_timeout))
	
	if Input.is_action_pressed('right'):
		$AnimatedSprite.flip_h = false
		if right_killable and dash != 0:
			print("kill!")
			position.x = enemy.position.x + enemy.direction*50
		else:
			velocity.x += (speed)*speed_multiplier + dash
		
		
	if Input.is_action_pressed('left'):
		$AnimatedSprite.flip_h = true
		if left_killable and dash != 0:
			print("kill!")
			position.x = enemy.position.x + enemy.direction*50
		else:
			velocity.x -= (speed)*speed_multiplier + dash
		
	
	if is_on_floor(): 
		# running animation
		if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			if $AnimatedSprite.animation != 'run': $AnimatedSprite.play('run') #prevent continuous replay of animation
		
		# idle animation
		else:
			$AnimatedSprite.play('default')
			if DEBUG: print('Animation changed to: ' + $AnimatedSprite.animation)		

	# jump
	if !is_on_floor():
		if jump_state == 0: jump_state = 2 
		# 0 is on floor, then 2 on air, 1 already double jump
	else:
		jump_state = 0
	if Input.is_action_just_pressed('jump'):
		if is_on_floor(): 
			velocity.y = jump_speed
			jump_state = 2 
			$AnimatedSprite.play("jump")
			if DEBUG: print('Current jump state is: ' + str(jump_state))
		if !is_on_floor() and jump_state == 2: #jump_state makes sure they can only double jump once
			GRAVITY = 1200 # to reset gravity at ladder
			velocity.y = jump_speed
			jump_state = 1
			$AnimatedSprite.play("double_jump")
			if DEBUG: print('Current jump state is: ' + str(jump_state))
	
	#crouch
	if is_on_floor() and Input.is_action_pressed("crouch"):
		speed_multiplier = 0.2
		if $AnimatedSprite.animation != 'jump': $AnimatedSprite.play("crouch") #fix crouching after jumping issue (1 frame still on floor)
		if DEBUG: print('Now crouching')
	else:
		speed_multiplier = 1
	
	#climb
	if climbable:
		if Input.is_action_just_pressed("up_ladder") or Input.is_action_just_pressed("down_ladder"):
			velocity.y = 0
			GRAVITY = 0
			jump_state = 2 # can only jump one more time at ladder
			
		if Input.is_action_pressed("up_ladder"):
			position.y -= climb_speed
			if $AnimatedSprite.animation != "climb": $AnimatedSprite.play("climb")
			
		if Input.is_action_pressed("down_ladder"):
			position.y += climb_speed
			if $AnimatedSprite.animation != "climb": $AnimatedSprite.play("climb")
		

func _physics_process(delta):
	velocity.y += delta * GRAVITY
	dash_timeout -= delta
	dash_cd_timeout -= delta
	get_input()
	velocity = move_and_slide(velocity, UP)


func _on_Climbable_body_entered(body):
	if (body.name == "Player" and body is KinematicBody2D):
		climbable = true
		


func _on_Climbable_body_exited(body):
	if (body.name == "Player" and body is KinematicBody2D):
		print("keloar")
		if is_on_floor(): $AnimatedSprite.play("run")
		else: $AnimatedSprite.play("jump")
		GRAVITY = 1200
		climbable = false


func _on_LeftKillCollision_body_entered(body):
	if body.name == "Zombie" and body is KinematicBody2D:
		enemy = body
		left_killable = true
		print("Right killable: " + str(left_killable))


func _on_RightKillCollision_body_entered(body):
	if body.name == "Zombie" and body is KinematicBody2D:
		enemy = body
		right_killable = true
		print("Left killable: "+ str(right_killable))


func _on_LeftKillCollision_body_exited(body):
	if body.name == "Zombie" and body is KinematicBody2D:
		enemy = body
		left_killable = false
	print("Left killable: "+ str(right_killable))

func _on_RightKillCollision_body_exited(body):
	if body.name == "Zombie" and body is KinematicBody2D:
		enemy = body
		right_killable = false
	print("Right killable: " + str(left_killable))
