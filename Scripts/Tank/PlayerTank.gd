extends "res://Scripts/Tank/Tank.gd"

class_name PlayerTank

# Max speed value, tank speed cant go higher than this value
const MAX_SPEED: float = 300.0
# Maximum and Minimum acceleration
const MAX_ACCEL: float = 5.0
const MIN_ACCEL: float = -MAX_ACCEL
# Breaks force
const BREAKS_FORCE: float = 7.0
# Tank friction value
var friction: float = 0.6
# Forward acceleration value
var acceleration: float
# Player tank move direction
var direction: Vector2



func _ready() -> void:
	Global.player = self
	
	return
	


func _physics_process(delta: float) -> void:
	# Using up, down keys to move the tank
	var input_accel: float = (Input.get_action_strength("ui_down") - 
			Input.get_action_strength("ui_up"))
	var turnStr: float = (Input.get_action_strength("ui_right") -
			Input.get_action_strength("ui_left"))
	
	var breaks_pressed: bool = Input.is_action_pressed("break")
	
	if input_accel == 0.0:
		acceleration = 0
	else:
		acceleration += input_accel
		if acceleration > MAX_ACCEL:
			acceleration = MAX_ACCEL
		elif acceleration < MIN_ACCEL:
			acceleration = MIN_ACCEL
	
	# Applying forward acceleration to speed
	speed += acceleration
	_apply_friction()
	if breaks_pressed:
		_apply_breaks()
	
	# Apply turn
	if speed < 5.0 && speed > -5.0:
		tank.rotation += turnStr * delta * 0.4
	else:
		tank.rotation += turnStr * delta
	
	speed = clamp(speed, -MAX_SPEED, MAX_SPEED)
	
	direction = Vector2(-cos(tank.rotation), -sin(tank.rotation))
	
	# Using mouse cursor position the tank barrel direction is set.
	shot_direction = Vector2.ZERO.direction_to(get_local_mouse_position())
	barrel.rotation = shot_direction.angle()
	
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
	newShot.setDirection(shot_direction)
	newShot.position = position
	newShot.z_index = z_index - 1
	get_tree().current_scene.call_deferred("add_child", newShot)
	
	return
	


func _apply_friction() -> void:
	if speed < -5:
		speed += friction
	elif speed > 5:
		speed -= friction
	elif acceleration == 0:
		speed = 0
		
	return
	


func _apply_breaks() -> void:
	# Apply breaks
	if speed < -5:
		speed += BREAKS_FORCE
	elif speed > 5:
		speed -= BREAKS_FORCE
	else:
		speed = 0.0
	
	return
	
