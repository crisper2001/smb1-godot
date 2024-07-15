extends StaticBody2D

const GRAVITY = 0.5
const JUMP = -2.8

var trigger = false

var v_speed = 0
var original_y = 0

func _ready():
	original_y = position.y

func _physics_process(_delta):
	if trigger:
		v_speed = JUMP
		trigger = false
	
	v_speed += GRAVITY
	
	position.y += v_speed
	position.y = clamp(position.y, original_y - 16, original_y)

func _on_area_2d_area_entered(area):
	if area.is_in_group("mario"):
		trigger = true
