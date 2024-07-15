extends CharacterBody2D

const ACC_SPD = 0.098 / 4 # Walking acceleration speed
const RUN_ACC_SPD = 0.144 / 4 # Running acceleration speed
const DEC_SPD = 0.03 # Release deceleration speed
const SKD_DEC_SPD = 0.04 # Skidding deceleration speed
const MAX_SPD = 1.900 # Maximum walking speed
const MAX_RUN_SPD = 2.900 # Maximum running speed
const GRAV = 0.05 # Gravity
const JMP_SPD = 3 * 0.7 # Jump speed

var h_spd = 0
var v_spd = 0

func _ready():
	#Engine.max_fps = 60
	pass

func _physics_process(_delta):
	var mov = Input.get_axis("left_key", "right_key")
	var running = Input.is_action_pressed("run_key")
	var dir = sign(h_spd)
	
	if mov != 0:
		if ($AnimationPlayer.current_animation != "jumping"):
			if (mov == -1):
				$Sprite2D.flip_h = true
			else:
				$Sprite2D.flip_h = false
		
		if h_spd != 0 && dir != mov:
			h_spd -= SKD_DEC_SPD * dir
			if is_on_floor():
				$AnimationPlayer.play("skidding")
		else:
			if running: 
				h_spd += RUN_ACC_SPD * mov
			else:
				h_spd += ACC_SPD * mov
			if is_on_floor() && $AnimationPlayer.current_animation != "jumping":
				$AnimationPlayer.play("walking")
	
	elif abs(h_spd) > 0:
		h_spd -= DEC_SPD * dir
		if $AnimationPlayer.current_animation != "skidding" && $AnimationPlayer.current_animation != "jumping":
			$AnimationPlayer.play("walking")
		if dir != sign(h_spd):
			h_spd = 0
			
	elif !is_on_floor():
		$AnimationPlayer.play("jumping")
		
	else:
		$AnimationPlayer.play("idle")
	
	if abs(h_spd) < 1:
		$AnimationPlayer.speed_scale = 0.5
	else:
		$AnimationPlayer.speed_scale = abs(h_spd)
	
	if Input.is_action_pressed("run_key"):
		h_spd = clamp(h_spd, -MAX_RUN_SPD, MAX_RUN_SPD)
	else:
		h_spd = clamp(h_spd, -MAX_SPD, MAX_SPD)
	
	if !is_on_floor():
		v_spd += GRAV
	elif Input.is_action_just_pressed("jump_key"):
		v_spd = -JMP_SPD
		$AnimationPlayer.play("jumping")
		$Jump_Sound.play()
	
	velocity.x = h_spd * 90
	velocity.y = v_spd * 90
	
	move_and_slide()
	
	if is_on_wall():
		h_spd = 0
	
	if position.y > 256:
		get_tree().reload_current_scene()
