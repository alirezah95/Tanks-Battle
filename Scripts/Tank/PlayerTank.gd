extends "res://Scripts/Tank/Tank.gd"

class_name PlayerTank

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
	Global.player = self
	
	return
	


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
	
	direction = Vector2(-cos(tank.rotation), -sin(tank.rotation))
	
	# Using mouse cursor position the tank barrel direction is set.
	barrelDirection = Vector2.ZERO.direction_to(get_local_mouse_position())
	barrel.rotation = barrelDirection.angle()
	
	if not isShotLocked:
		if Input.is_action_pressed("shot"):
			_shot()
	
	move_and_slide(direction * speed)
	
	return
	


func _shot() -> void:
	isShotLocked = true
	shotLockTmr.start()
	
	# Instancing a shot object
	var newShot: Shot = Global.playerShotScn.instance()
	newShot.setDirection(barrelDirection)
	newShot.position = position
	newShot.z_index = z_index - 1
	get_tree().current_scene.call_deferred("add_child", newShot)
	
	return
	


func _applyFriction() -> void:
	if speed < -5:
		speed += friction
	elif speed > 5:
		speed -= friction
	elif acceleration == 0:
		speed = 0
		
	return
	


