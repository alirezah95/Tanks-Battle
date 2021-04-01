extends "res://Scripts/Tank/Tank.gd"

const PI_2: float = PI / 2
# Max speed value, tank speed cant go higher than this value
const MAX_SPEED: float = 200.0
# Player tank move current speed
var speed: float = 0
# Tank friction value
var friction: float = 0.7
# Forward acceleration value
var acceleration: float
# Player tank move direction
var direction: Vector2



func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	# Using up, down keys to move the tank
	acceleration = (Input.get_action_strength("ui_down") - 
			Input.get_action_strength("ui_up")) * 2.5
	var turnStr: float = (Input.get_action_strength("ui_right") -
			Input.get_action_strength("ui_left"))
	
	if acceleration == 0:
		tank.rotation += turnStr * delta * 0.4
	else:
		tank.rotation += turnStr * delta
	# Applying forward acceleration to speed
	speed += acceleration
	_applyFriction()
	speed = clamp(speed, -MAX_SPEED, MAX_SPEED)
	
	direction = Vector2(-sin(tank.rotation), cos(tank.rotation))
	
	move_and_slide(direction * speed)
	
	# Using mouse cursor position the tank barrel direction is set.
	barrel.rotation = get_local_mouse_position().angle() + PI_2
	
	return
	


func _applyFriction() -> void:
	if speed < -5:
		speed += friction
	elif speed > 5:
		speed -= friction
	elif acceleration == 0:
		speed = 0
		
	return
	
