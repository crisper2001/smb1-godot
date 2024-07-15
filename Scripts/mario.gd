extends CharacterBody2D

const JUMP_SPEED = -250
const TERMINAL_SPEED = 300
const GRAVITY = 24
const WALKING_ACCELERATION = 2
const RUNNING_ACCELRATION = 3
const MAXIMUM_WALK_SPEED = 90
const MAXIMUM_RUNNING_SPEED = 160
const RELEASE_DECELERATION = 3
const SKIDDING_DECELERATION = 7

var h_speed = 0
var v_speed = 0

func _physics_process(delta):
	var movement = Input.get_axis("left_key", "right_key")
	var jump_pressed = Input.is_action_pressed("jump_key")
	var jump_just_pressed = Input.is_action_just_pressed("jump_key")
	var direction = sign(h_speed)
	var run_pressed = Input.is_action_pressed("run_key")
	
	## MOVEMENT PHYSICS
	
	if movement != 0:
		if abs(h_speed) > 0 and movement != direction:
			h_speed -= SKIDDING_DECELERATION * direction
			if is_on_floor():
				$AnimationPlayer.play("skidding")
		else:
			if !run_pressed:
				h_speed += WALKING_ACCELERATION * movement
			else:
				h_speed += RUNNING_ACCELRATION * movement
			if is_on_floor():
				$AnimationPlayer.play("walking")
			
	elif is_on_floor():
		h_speed -= RELEASE_DECELERATION * direction
		
		if $AnimationPlayer.current_animation != "skidding":
			$AnimationPlayer.play("walking")
		
		if direction != sign(h_speed):
			h_speed = 0
	
	if is_on_floor() and !run_pressed:
		h_speed = clamp(h_speed, -MAXIMUM_WALK_SPEED, MAXIMUM_WALK_SPEED)
	else:
		h_speed = clamp(h_speed, -MAXIMUM_RUNNING_SPEED, MAXIMUM_RUNNING_SPEED)
	
	## JUMPING PHYSICS

	if !is_on_floor():
		if jump_pressed and v_speed <= 0:
			if abs(h_speed) < MAXIMUM_WALK_SPEED:
				v_speed -= GRAVITY * 0.665
			elif abs(h_speed) < MAXIMUM_RUNNING_SPEED:
				v_speed -= GRAVITY * 0.685
			else:
				v_speed -= GRAVITY * 0.7
		v_speed += GRAVITY
	elif jump_just_pressed:
		v_speed = JUMP_SPEED
		$JumpSound.play()
	else:
		v_speed = 0
	
	## ANIMATIONS
	
	if $AnimationPlayer.current_animation == "walking":
		if is_on_floor():
			$AnimationPlayer.speed_scale = abs(h_speed) * 0.015
			$AnimationPlayer.speed_scale = clamp($AnimationPlayer.speed_scale, 0.8, 2.5)
		else:
			$AnimationPlayer.speed_scale = 0
	
	if h_speed == 0 and v_speed == 0:
		$AnimationPlayer.play("idle")
	
	if v_speed < 0:
		$AnimationPlayer.play("jumping")
	#		
	if is_on_floor():
		if movement == -1:
			$Sprite2D.flip_h = true
		elif movement == 1:
			$Sprite2D.flip_h = false
	
	## ASSIGNMENTS

	v_speed = clamp(v_speed, JUMP_SPEED, TERMINAL_SPEED)
	
	velocity.x = h_speed * delta * Engine.physics_ticks_per_second
	velocity.y = v_speed * delta * Engine.physics_ticks_per_second
	
	move_and_slide()
	
	## COLLISIONS
	
	if is_on_wall():
		h_speed = 0
		
	if is_on_ceiling():
		if $JumpSound.playing == true:
			$JumpSound.stop()
		$BumpSound.play()
		v_speed = 0
		
	## DEATH
	
	if position.y > 256 || Input.is_action_just_pressed("restart_key"):
		get_tree().reload_current_scene()
