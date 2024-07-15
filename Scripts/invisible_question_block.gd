extends StaticBody2D

const GRAVITY = 0.5
const JUMP = -2.8

var activated = true
var trigger = false

var v_speed = 0
var original_y = 0

func _ready():
	visible = false
	$ColissionShape1.disabled = true
	original_y = position.y

func _physics_process(_delta):
	if activated:
		$AnimationPlayer.play("activated")
	else:
		$AnimationPlayer.play("deactivated")
		$ColissionShape1.disabled = false
		visible = true
		if trigger:
			v_speed = JUMP
			trigger = false
		
		v_speed += GRAVITY
		
		position.y += v_speed
		position.y = clamp(position.y, original_y - 16, original_y)

func _on_area_2d_area_entered(area):
	if area.is_in_group("mario") and activated and get_tree().get_first_node_in_group("player").velocity.y < 0:
		$CoinSound.play()
		activated = false
		trigger = true
